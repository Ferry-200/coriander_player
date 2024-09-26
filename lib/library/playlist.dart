// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:coriander_player/library/audio_library.dart';
import 'package:path_provider/path_provider.dart';

List<Playlist> PLAYLISTS = [];

Future<void> readPlaylists() async {
  final supportPath = (await getApplicationSupportDirectory()).path;
  final playlistsPath = "$supportPath\\playlists.json";

  final playlistsStr = File(playlistsPath).readAsStringSync();
  final List playlistsJson = json.decode(playlistsStr);

  for (Map item in playlistsJson) {
    PLAYLISTS.add(Playlist.fromMap(item));
  }
}

Future<void> savePlaylists() async {
  final supportPath = (await getApplicationSupportDirectory()).path;
  final playlistsPath = "$supportPath\\playlists.json";

  List<Map> playlistMaps = [];
  for (final item in PLAYLISTS) {
    playlistMaps.add(item.toMap());
  }

  final playlistsJson = json.encode(playlistMaps);
  final output = await File(playlistsPath).create(recursive: true);
  await output.writeAsString(playlistsJson);
}

class Playlist {
  String name;

  /// path, audio
  Map<String, Audio> audios;

  Playlist(this.name, this.audios);

  Map toMap() {
    final List<Map> audioMaps = [];
    for (var item in audios.values) {
      audioMaps.add(item.toMap());
    }
    return {"name": name, "audios": audioMaps};
  }

  factory Playlist.fromMap(Map map) {
    final Map<String, Audio> audios = {};
    final List audioMaps = map["audios"];
    for (var item in audioMaps) {
      final audio = Audio.fromMap(item);
      audios[audio.path] = audio;
    }
    return Playlist(map["name"], audios);
  }
}
