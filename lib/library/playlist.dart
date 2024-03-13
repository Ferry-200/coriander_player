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
  final output = await File(playlistsPath).create();
  await output.writeAsString(playlistsJson);
}

class Playlist {
  String name;
  List<Audio> audios;

  Playlist(this.name, this.audios);

  Map toMap() => {
        "name": name,
        "audios": List.generate(audios.length, (i) => audios[i].toMap())
      };

  factory Playlist.fromMap(Map map) {
    final List audioMaps = map["audios"];
    return Playlist(
      map["name"],
      List.generate(audioMaps.length, (i) => Audio.fromMap(audioMaps[i])),
    );
  }
}
