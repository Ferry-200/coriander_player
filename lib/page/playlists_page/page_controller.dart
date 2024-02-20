import 'package:coriander_player/playlist.dart';
import 'package:flutter/foundation.dart';

class PlayListsPageController with ChangeNotifier {
  void newPlaylist(String name) {
    PLAYLISTS.add(Playlist(name, []));
    notifyListeners();
  }

  void editPlaylist(Playlist playlist, String name) {
    playlist.name = name;
    notifyListeners();
  }

  void removePlaylist(Playlist playlist) {
    PLAYLISTS.remove(playlist);
    notifyListeners();
  }
}
