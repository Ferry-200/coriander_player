import 'dart:convert';
import 'dart:io';

import 'package:desktop_lyric/message.dart';
import 'package:flutter/material.dart';

class PlayerStates {
  ValueNotifier<PlayerAction> playerAction = ValueNotifier(PlayerAction.START);
  ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.light);
  ValueNotifier<ThemeChangedMessage> themeChanged = ValueNotifier(
    ThemeChangedMessage(
      primary: const Color(0xff63a002),
      surfaceContainer: const Color(0xffeeefe3),
      onSurface: const Color(0xff1a1c16),
    ),
  );
  ValueNotifier<NowPlayingChangedMessage> nowPlaying = ValueNotifier(
    NowPlayingChangedMessage(title: "无", artist: "无", album: "无"),
  );
  ValueNotifier<LyricLineMessage> lyricLine = ValueNotifier(LyricLineMessage(
    content: "无",
    translation: "无",
    length: Duration.zero,
  ));

  /// args[0]: now playing changed message
  /// args[1]: theme mode changed message
  /// args[2]: theme changed message
  static void initWithArgs(List<String> args) {
    if (args.length > 3) return;

    _instance = PlayerStates();
    try {
      _instance!.nowPlaying.value = NowPlayingChangedMessage.fromMap(
        json.decode(args[0]),
      );
      _instance!.themeMode.value = ThemeModeChangedMessage.fromMap(
        json.decode(args[1]),
      ).isDarkMode
          ? ThemeMode.dark
          : ThemeMode.light;
      _instance!.themeChanged.value = ThemeChangedMessage.fromMap(
        json.decode(args[2]),
      );
    } catch (_) {}
  }

  static PlayerStates? _instance;
  static PlayerStates get instance {
    _instance ??= PlayerStates();
    return _instance!;
  }

  PlayerStates() {
    stdin.transform(utf8.decoder).listen((event) {
      try {
        final Map messageMap = json.decode(event);
        final String type = messageMap["type"];

        if (type == "PlayerActionMessage") {
          final action = PlayerActionMessage.fromMap(messageMap).action;
          if (action != null) {
            playerAction.value = action;
          }
        }

        if (type == "ThemeModeChangedMessage") {
          themeMode.value =
              ThemeModeChangedMessage.fromMap(messageMap).isDarkMode
                  ? ThemeMode.dark
                  : ThemeMode.light;
        }

        if (type == "ThemeChangedMessage") {
          themeChanged.value = ThemeChangedMessage.fromMap(messageMap);
        }

        if (type == "NowPlayingChangedMessage") {
          nowPlaying.value = NowPlayingChangedMessage.fromMap(messageMap);
        }

        if (type == "LyricLineMessage") {
          lyricLine.value = LyricLineMessage.fromMap(messageMap);
        }
      } catch (_) {}
    });
  }
}
