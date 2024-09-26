import 'dart:io';
import 'dart:convert';
import 'dart:ui';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:flutter/painting.dart';

/// from index.json
class AudioLibrary {
  List<AudioFolder> folders;

  AudioLibrary._(this.folders);

  /// 所有音乐
  late List<Audio> audioCollection;

  Map<String, Artist> artistCollection = {};

  Map<String, Album> albumCollection = {};

  /// must call [initFromIndex]
  static late AudioLibrary instance;

  /// 目前 index 结构：
  /// ```json
  /// {
  ///     "folders": [
  ///         {
  ///             "audios": [
  ///                 {...},
  ///                 ...
  ///             ],
  ///             ...
  ///         },
  ///         ...
  ///     ],
  ///     "version": 110
  /// }
  /// ```
  static Future<void> initFromIndex() async {
    final supportPath = (await getAppDataDir()).path;
    final indexPath = "$supportPath\\index.json";

    final indexStr = File(indexPath).readAsStringSync();
    final Map indexJson = json.decode(indexStr);
    final List foldersJson = indexJson["folders"];
    final List<AudioFolder> folders = [];

    for (Map folderMap in foldersJson) {
      final List audiosJson = folderMap["audios"];
      final List<Audio> audios = [];
      for (Map audioMap in audiosJson) {
        audios.add(Audio.fromMap(audioMap));
      }
      folders.add(AudioFolder.fromMap(folderMap, audios));
    }

    instance = AudioLibrary._(folders);

    instance.artistCollection.clear();
    instance.albumCollection.clear();
    instance._buildCollections();
  }

  void _buildCollections() {
    instance.audioCollection = folders.fold(
      [],
      (previousValue, element) => previousValue += element.audios,
    );

    for (Audio audio in audioCollection) {
      for (String artistName in audio.splitedArtists) {
        /// 如果artistCollection中有artistName指向的artist，putIfAbsent会返回该artist。
        /// 随后往这个artist里添加该audio。
        ///
        /// 如果没有，创建一个名字为artistName的空艺术家，并将artistName与之相连。
        /// 随后往这个artist里添加该audio。
        artistCollection
            .putIfAbsent(artistName, () => Artist(name: artistName))
            .works
            .add(audio);
      }

      /// 如果albumCollection中有audio.album指向的album，putIfAbsent会返回该album。
      /// 随后往这个album里添加该audio。
      ///
      /// 如果没有，创建一个名字为audio.album的空艺术家，并将audio.album与之相连。
      /// 随后往这个album里添加该audio。
      albumCollection
          .putIfAbsent(audio.album, () => Album(name: audio.album))
          .works
          .add(audio);
    }

    /// 将艺术家和专辑链接起来
    for (Artist artist in artistCollection.values) {
      for (Audio audio in artist.works) {
        artist.albumsMap.putIfAbsent(
          audio.album,
          () => albumCollection[audio.album]!,
        );
      }
    }

    /// 将专辑和艺术家链接起来
    for (Album album in albumCollection.values) {
      for (Audio audio in album.works) {
        for (String artistName in audio.splitedArtists) {
          album.artistsMap.putIfAbsent(
            artistName,
            () => artistCollection[artistName]!,
          );
        }
      }
    }
  }

  @override
  String toString() {
    return folders.toString();
  }
}

class AudioFolder {
  List<Audio> audios;

  /// absolute path
  String path;

  /// secs since UNIX EPOCH
  int modified;

  /// secs since UNIX EPOCH
  int latest;

  AudioFolder(this.audios, this.path, this.modified, this.latest);

  factory AudioFolder.fromMap(Map map, List<Audio> audios) =>
      AudioFolder(audios, map["path"], map["modified"], map["latest"]);

  @override
  String toString() {
    return {
      "audios": audios.toString(),
      "path": path,
      "modified":
          DateTime.fromMillisecondsSinceEpoch(modified * 1000).toString(),
    }.toString();
  }
}

class Audio {
  String title;

  /// 从音乐标签中读取的艺术家字符串，可能包含多个艺术家，以“、”，“/”等分隔。
  String artist;

  /// 分割[artist]得到的结果
  List<String> splitedArtists;

  String album;

  /// 0: 没有track
  int track;

  /// audio's duration in secs
  int duration;

  /// kbps
  int? bitrate;

  int? sampleRate;

  /// absolute path
  String path;

  /// secs since UNIX EPOCH
  int modified;

  /// secs since UNIX EPOCH
  int created;

  /// 标签来源（Lofty、Windows、null）
  String? by;

  ImageProvider? _cover;

  /// 以“、”和“/”分割艺术家，会把名称中带有这些符号的艺术家分割。
  /// 暂时想不到别的方法。
  Audio(
    this.title,
    this.artist,
    this.album,
    this.track,
    this.duration,
    this.bitrate,
    this.sampleRate,
    this.path,
    this.modified,
    this.created,
    this.by,
  ) : splitedArtists = artist.split(
          RegExp(AppSettings.instance.artistSplitPattern),
        );

  factory Audio.fromMap(Map map) => Audio(
        map["title"],
        map["artist"],
        map["album"],
        map["track"] ?? 0,
        map["duration"] ?? 0,
        map["bitrate"],
        map["sample_rate"],
        map["path"],
        map["modified"],
        map["created"],
        map["by"],
      );

  Map toMap() => {
        "title": title,
        "artist": artist,
        "album": album,
        "track": track,
        "duration": duration,
        "bitrate": bitrate,
        "sample_rate": sampleRate,
        "path": path,
        "modified": modified,
        "created": created,
        "by": by
      };

  /// 缓存ImageProvider而不是Uint8List（bytes）
  /// 缓存bytes时，每次加载图片都要重新解码，内存占用很大。快速滚动时能到700mb
  /// 缓存ImageProvider不用重新解码。快速滚动时最多250mb
  /// 48*48
  Future<ImageProvider?> get cover {
    if (_cover == null) {
      return getPictureFromPath(path: path).then((value) {
        if (value == null) {
          return null;
        }

        // _cover = ResizeImage.resizeIfNeeded(48, 48, MemoryImage(value));
        _cover = ResizeImage(
          MemoryImage(value),
          width: 48,
          height: 48,
          policy: ResizeImagePolicy.fit,
        );
        return _cover;
      });
    }
    return Future.value(_cover!);
  }

  /// audio detail page 不需要频繁调用，所以不缓存图片
  /// 200 * 200
  Future<ImageProvider?> get mediumCover =>
      getPictureFromPath(path: path).then((value) {
        if (value == null) {
          return null;
        }
        return ResizeImage(
          MemoryImage(value),
          width: 200,
          height: 200,
          policy: ResizeImagePolicy.fit,
        );
      });

  /// now playing 不需要频繁调用，所以不缓存图片
  /// size: 400 * devicePixelRatio（屏幕缩放大小）
  Future<ImageProvider?> get largeCover =>
      getPictureFromPath(path: path).then((value) {
        if (value == null) {
          return null;
        }
        final pixelRatio =
            PlatformDispatcher.instance.views.first.devicePixelRatio;
        final size = (400 * pixelRatio).round();
        return ResizeImage(
          MemoryImage(value),
          width: size,
          height: size,
          policy: ResizeImagePolicy.fit,
        );
      });

  @override
  String toString() {
    return {
      "title": title,
      "artist": artist,
      "album": album,
      "path": path,
      "modified":
          DateTime.fromMillisecondsSinceEpoch(modified * 1000).toString(),
      "created": DateTime.fromMillisecondsSinceEpoch(created * 1000).toString(),
    }.toString();
  }
}

class Artist {
  String name;

  /// 所有专辑
  Map<String, Album> albumsMap = {};

  /// 作品
  List<Audio> works = [];

  /// 只能用在artist detail page
  /// 200*200
  Future<ImageProvider?> get picture =>
      getPictureFromPath(path: works.first.path).then((value) {
        if (value == null) {
          return null;
        }
        return ResizeImage.resizeIfNeeded(200, 200, MemoryImage(value));
      });

  Artist({required this.name});
}

class Album {
  String name;

  /// 参与的艺术家
  Map<String, Artist> artistsMap = {};

  /// 作品
  List<Audio> works = [];

  /// 只能用在album detail page
  /// 200*200
  Future<ImageProvider?> get cover =>
      getPictureFromPath(path: works.first.path).then((value) {
        if (value == null) {
          return null;
        }
        return ResizeImage.resizeIfNeeded(200, 200, MemoryImage(value));
      });

  Album({required this.name});
}
