import 'dart:convert';
import 'dart:io';

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/utils.dart';

enum LyricSourceType {
  qq("qq"),
  kugou("kugou"),
  netease("netease"),
  local("local");

  final String name;
  const LyricSourceType(this.name);
}

/// 默认歌词来源
class LyricSource {
  LyricSourceType source;
  int? qqSongId;
  String? kugouSongHash;
  String? neteaseSongId;

  LyricSource(this.source,
      {this.qqSongId, this.kugouSongHash, this.neteaseSongId});

  static LyricSource fromMap(Map map) {
    if (map["source"] == "qq") {
      return LyricSource(LyricSourceType.qq, qqSongId: map["id"]);
    } else if (map["source"] == "kugou") {
      return LyricSource(LyricSourceType.kugou, kugouSongHash: map["id"]);
    } else if (map["source"] == "netease") {
      return LyricSource(LyricSourceType.netease, neteaseSongId: map["id"]);
    } else {
      return LyricSource(LyricSourceType.local);
    }
  }

  Map toMap() {
    switch (source) {
      case LyricSourceType.qq:
        return {"source": source.name, "id": qqSongId};
      case LyricSourceType.kugou:
        return {"source": source.name, "id": kugouSongHash};
      case LyricSourceType.netease:
        return {"source": source.name, "id": neteaseSongId};
      case LyricSourceType.local:
        return {"source": source.name, "id": null};
    }
  }
}

Map<String, LyricSource> LYRIC_SOURCES = {};

Future<void> readLyricSources() async {
  try {
    final supportPath = (await getAppDataDir()).path;
    final lyricSourcePath = "$supportPath\\lyric_source.json";

    final lyricSourceStr = File(lyricSourcePath).readAsStringSync();
    final Map lyricSourceJson = json.decode(lyricSourceStr);

    for (final item in lyricSourceJson.entries) {
      if (File(item.key).existsSync() == false) continue;
      LYRIC_SOURCES[item.key] = LyricSource.fromMap(item.value);
    }
  } catch (err, trace) {
    LOGGER.e(err, stackTrace: trace);
  }
}

Future<void> saveLyricSources() async {
  try {
    final supportPath = (await getAppDataDir()).path;
    final lyricSourcePath = "$supportPath\\lyric_source.json";

    Map<String, Map> lyricSourceMaps = {};
    for (final item in LYRIC_SOURCES.entries) {
      lyricSourceMaps[item.key] = item.value.toMap();
    }

    final lyricSourceJson = json.encode(lyricSourceMaps);
    final output = await File(lyricSourcePath).create(recursive: true);
    await output.writeAsString(lyricSourceJson);
  } catch (err, trace) {
    LOGGER.e(err, stackTrace: trace);
  }
}
