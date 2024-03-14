import 'dart:convert';
import 'dart:math';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/krc.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/lyric/qrc.dart';
import 'package:coriander_player/music_api/api/kugou/kugou.dart';
import 'package:coriander_player/music_api/api/netease/netease.dart';
import 'package:coriander_player/music_api/api/qq/qq.dart';

enum ResultSource { qq, kugou, netease }

double _computeScore(Audio audio, String title, String artists, String album) {
  int maxScore = audio.title.length + audio.artist.length + audio.album.length;
  int score = 0;

  int minTitleLength = min(audio.title.length, title.length);
  for (int i = 0; i < minTitleLength; ++i) {
    if (audio.title[i] == title[i]) score += 1;
  }

  int minArtistLength = min(audio.artist.length, artists.length);
  for (int i = 0; i < minArtistLength; ++i) {
    if (audio.artist[i] == artists[i]) score += 1;
  }

  int minAlbumLength = min(audio.album.length, album.length);
  for (int i = 0; i < minAlbumLength; ++i) {
    if (audio.album[i] == album[i]) score += 1;
  }

  return score / maxScore;
}

class SongSearchResult {
  ResultSource source;
  String title;
  String artists;
  String album;
  double score;

  /// for qq result
  int? qqSongId;

  /// for netease result
  String? neteaseSongId;

  /// for kugou result
  String? kugouSongHash;

  SongSearchResult(
      this.source, this.title, this.artists, this.album, this.score,
      {this.qqSongId, this.neteaseSongId, this.kugouSongHash});

  @override
  String toString() {
    return json.encode({
      "source": source.toString(),
      "title": title,
      "artists": artists,
      "album": album,
      "score": score,
    });
  }

  static SongSearchResult fromQQSearchResult(Map itemSong, Audio audio) {
    final List singer = itemSong["singer"];
    final buffer = StringBuffer(singer.first["name"]);
    for (int i = 1; i < singer.length; ++i) {
      buffer.write("、${singer[i]["name"]}");
    }

    final title = itemSong["name"] ?? "";
    final album = itemSong["album"]["title"] ?? "";
    final artists = buffer.toString();

    return SongSearchResult(
      ResultSource.qq,
      title,
      artists,
      album,
      _computeScore(audio, title, artists, album),
      qqSongId: itemSong["id"],
    );
  }

  static SongSearchResult fromNeteaseSearchResult(Map song, Audio audio) {
    final title = song["name"] ?? "";

    final List artistList = song["artists"];
    final buffer = StringBuffer(artistList.first["name"]);
    for (int i = 1; i < artistList.length; ++i) {
      buffer.write("、${artistList[i]["name"]}");
    }
    final artists = buffer.toString();

    final album = song["album"]["name"] ?? "";

    return SongSearchResult(
      ResultSource.netease,
      title,
      artists,
      album,
      _computeScore(audio, title, artists, album),
      neteaseSongId: song["id"].toString(),
    );
  }

  static SongSearchResult fromKugouSearchResult(Map info, Audio audio) {
    final title = info["songname"];
    final album = info["album_name"];
    final artists = info["singername"];

    return SongSearchResult(
      ResultSource.kugou,
      title,
      artists,
      album,
      _computeScore(audio, title, artists, album),
      kugouSongHash: info["hash"],
    );
  }
}

Future<List<SongSearchResult>> _uniSearch(Audio audio) async {
  final query = audio.title;
  List<SongSearchResult> result = [];

  final Map qqAnswer = (await QQ.search(keyWord: query)).data;
  final List qqResultList = qqAnswer["req"]["data"]["body"]["item_song"];
  for (var itemSong in qqResultList) {
    result.add(SongSearchResult.fromQQSearchResult(itemSong, audio));
  }

  final Map kugouAnswer = (await KuGou.searchSong(keyword: query)).data;
  final List kugouResultList = kugouAnswer["data"]["info"];
  for (var info in kugouResultList) {
    result.add(SongSearchResult.fromKugouSearchResult(info, audio));
  }

  final Map neteaseAnswer = (await Netease.search(keyWord: query)).data;
  final List neteaseResultList = neteaseAnswer["result"]["songs"];
  for (var song in neteaseResultList) {
    result.add(SongSearchResult.fromNeteaseSearchResult(song, audio));
  }

  result.sort((a, b) => b.score.compareTo(a.score));
  return result;
}

Future<Lrc?> _getNeteaseUnsyncLyric(String neteaseSongId) async {
  final answer = await Netease.lyric(id: neteaseSongId);
  final lrcText = answer.data;
  if (lrcText is String) {
    return Lrc.fromLrcText(lrcText, LrcSource.web);
  }

  return null;
}

Future<Lrc?> _getQQUnsyncLyric(int qqSongId) async {
  final answer = await QQ.songLyric(songId: qqSongId);
  final lrcText = answer.data["lyric"];
  if (lrcText is String) {
    return Lrc.fromLrcText(lrcText, LrcSource.web);
  }

  return null;
}

Future<Lrc?> _getKugouUnsyncLyric(String kugouSongHash) async {
  final answer = await KuGou.lrc(hash: kugouSongHash);
  final lrcText = answer.data["data"]["lrc"];
  if (lrcText is String) {
    return Lrc.fromLrcText(lrcText, LrcSource.web);
  }

  return null;
}

Future<Qrc?> _getQQSyncLyric(int qqSongId) async {
  final answer = await QQ.songLyric3(songId: qqSongId);
  final qrcText = answer.data["lyric"];
  if (qrcText is String) {
    return Qrc.fromQrcText(qrcText);
  }

  return null;
}

Future<Krc?> _getKugouSyncLyric(String kugouSongHash) async {
  final answer = await KuGou.krc(hash: kugouSongHash);
  final krcText = answer.data["lyric"];
  if (krcText is String) {
    return Krc.fromKrcText(krcText);
  }

  return null;
}

Future<Lyric?> getMostMatchedLyric(Audio audio) async {
  final unisearchResult = await _uniSearch(audio);
  if (unisearchResult.isEmpty) return null;

  final mostMatch = unisearchResult.first;
  switch (mostMatch.source) {
    case ResultSource.qq:
      {
        final syncLyric = await _getQQSyncLyric(mostMatch.qqSongId!);
        if (syncLyric != null) return syncLyric;

        final unsyncLyric = await _getQQUnsyncLyric(mostMatch.qqSongId!);
        if (unsyncLyric != null) return unsyncLyric;

        return null;
      }
    case ResultSource.kugou:
      {
        final syncLyric = await _getKugouSyncLyric(mostMatch.kugouSongHash!);
        if (syncLyric != null) return syncLyric;

        final unsyncLyric =
            await _getKugouUnsyncLyric(mostMatch.kugouSongHash!);
        if (unsyncLyric != null) return unsyncLyric;

        return null;
      }
    case ResultSource.netease:
      {
        final unsyncLyric =
            await _getNeteaseUnsyncLyric(mostMatch.neteaseSongId!);
        if (unsyncLyric != null) return unsyncLyric;

        return null;
      }
  }
}
