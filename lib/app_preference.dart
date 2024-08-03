import 'dart:convert';
import 'dart:io';

import 'package:coriander_player/page/now_playing_page/component/lyric_view_controls.dart';
import 'package:coriander_player/page/now_playing_page/page.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:coriander_player/play_service/playback_service.dart';
import 'package:path_provider/path_provider.dart';

class PagePreference {
  int sortMethod;
  SortOrder sortOrder;
  ContentView contentView;

  PagePreference(this.sortMethod, this.sortOrder, this.contentView);

  Map toMap() => {
        "sortMethod": sortMethod,
        "sortOrder": sortOrder.name,
        "contentView": contentView.name,
      };

  factory PagePreference.fromMap(Map map) => PagePreference(
        map["sortMethod"] ?? 0,
        SortOrder.fromString(map["sortOrder"]) ?? SortOrder.ascending,
        ContentView.fromString(map["contentView"]) ?? ContentView.list,
      );
}

class NowPlayingPagePreference {
  NowPlayingViewMode nowPlayingViewMode;
  LyricTextAlign lyricTextAlign;
  double lyricFontSize;
  double translationFontSize;

  NowPlayingPagePreference(
    this.nowPlayingViewMode,
    this.lyricTextAlign,
    this.lyricFontSize,
    this.translationFontSize,
  );

  Map toMap() => {
        "nowPlayingViewMode": nowPlayingViewMode.name,
        "lyricTextAlign": lyricTextAlign.name,
        "lyricFontSize": lyricFontSize,
        "translationFontSize": translationFontSize,
      };

  factory NowPlayingPagePreference.fromMap(Map map) {
    return NowPlayingPagePreference(
      NowPlayingViewMode.fromString(map["nowPlayingViewMode"]) ??
          NowPlayingViewMode.withLyric,
      LyricTextAlign.fromString(map["lyricTextAlign"]) ?? LyricTextAlign.left,
      map["lyricFontSize"] ?? 22.0,
      map["translationFontSize"] ?? 18.0,
    );
  }
}

class PlaybackPreference {
  PlayMode playMode;
  double volumeDsp;

  PlaybackPreference(this.playMode, this.volumeDsp);

  Map toMap() => {
        "playMode": playMode.name,
        "volumeDsp": volumeDsp,
      };

  factory PlaybackPreference.fromMap(Map map) => PlaybackPreference(
        PlayMode.fromString(map["playMode"]) ?? PlayMode.forward,
        map["volumeDsp"] ?? 1.0,
      );
}

class AppPreference {
  var audiosPagePref = PagePreference(0, SortOrder.ascending, ContentView.list);

  var artistsPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.table);

  var artistDetailPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.list);

  var albumsPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.table);

  var albumDetailPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.list);

  var foldersPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.list);

  var folderDetailPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.list);

  var playlistsPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.list);

  var playlistDetailPagePref =
      PagePreference(0, SortOrder.ascending, ContentView.list);

  int startPage = 0;

  var playbackPref = PlaybackPreference(PlayMode.forward, 1.0);

  var nowPlayingPagePref = NowPlayingPagePreference(
      NowPlayingViewMode.withLyric, LyricTextAlign.left, 22.0, 18.0);

  Future<void> save() async {
    final supportPath = (await getApplicationSupportDirectory()).path;
    final appPreferencePath = "$supportPath\\app_preference.json";

    Map prefMap = {
      "audiosPagePref": audiosPagePref.toMap(),
      "artistsPagePref": artistsPagePref.toMap(),
      "artistDetailPagePref": artistDetailPagePref.toMap(),
      "albumsPagePref": albumsPagePref.toMap(),
      "albumDetailPagePref": albumDetailPagePref.toMap(),
      "foldersPagePref": foldersPagePref.toMap(),
      "folderDetailPagePref": folderDetailPagePref.toMap(),
      "playlistsPagePref": playlistsPagePref.toMap(),
      "playlistDetailPagePref": playlistDetailPagePref.toMap(),
      "startPage": startPage,
      "playbackPref": playbackPref.toMap(),
      "nowPlayingPagePref": nowPlayingPagePref.toMap(),
    };

    final prefJson = json.encode(prefMap);
    final output = await File(appPreferencePath).create();
    await output.writeAsString(prefJson);
  }

  static Future<void> read() async {
    final supportPath = (await getApplicationSupportDirectory()).path;
    final appPreferencePath = "$supportPath\\app_preference.json";

    final prefJson = await File(appPreferencePath).readAsString();
    final Map prefMap = json.decode(prefJson);

    instance.audiosPagePref = PagePreference.fromMap(prefMap["audiosPagePref"]);
    instance.artistsPagePref =
        PagePreference.fromMap(prefMap["artistsPagePref"]);
    instance.artistDetailPagePref = PagePreference.fromMap(
      prefMap["artistDetailPagePref"],
    );
    instance.albumsPagePref = PagePreference.fromMap(prefMap["albumsPagePref"]);
    instance.albumDetailPagePref = PagePreference.fromMap(
      prefMap["albumDetailPagePref"],
    );
    instance.foldersPagePref =
        PagePreference.fromMap(prefMap["foldersPagePref"]);
    instance.folderDetailPagePref = PagePreference.fromMap(
      prefMap["folderDetailPagePref"],
    );
    instance.playlistsPagePref = PagePreference.fromMap(
      prefMap["playlistsPagePref"],
    );
    instance.playlistDetailPagePref = PagePreference.fromMap(
      prefMap["playlistDetailPagePref"],
    );
    instance.startPage = prefMap["startPage"];
    instance.playbackPref = PlaybackPreference.fromMap(prefMap["playbackPref"]);
    instance.nowPlayingPagePref = NowPlayingPagePreference.fromMap(prefMap["nowPlayingPagePref"]);
  }

  static final AppPreference instance = AppPreference();
}
