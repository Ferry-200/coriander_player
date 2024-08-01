// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';

abstract class DesktopLyricMessage {
  DesktopLyricMessage();

  Map toMap() => {"type": "DesktopLyricMessage"};
}

enum PlayerAction {
  PAUSE,
  START,
  PREVIOUS_AUDIO,
  NEXT_AUDIO,
  CLOSE_DESKTOP_LYRIC;

  static PlayerAction? fromName(String name) {
    for (var item in PlayerAction.values) {
      if (item.name == name) return item;
    }
    return null;
  }
}

class PlayerActionMessage extends DesktopLyricMessage {
  final PlayerAction? action;

  PlayerActionMessage({required this.action});

  @override
  Map toMap() => {
        "type": "PlayerActionMessage",
        "action": action?.name,
      };

  @override
  String toString() => json.encode(toMap());

  factory PlayerActionMessage.fromMap(Map map) => PlayerActionMessage(
        action: PlayerAction.fromName(map["action"]),
      );
}

class ThemeModeChangedMessage extends DesktopLyricMessage {
  final bool isDarkMode;

  ThemeModeChangedMessage({required this.isDarkMode});

  @override
  Map toMap() => {
        "type": "ThemeModeChangedMessage",
        "isDarkMode": isDarkMode,
      };
  @override
  String toString() => json.encode(toMap());

  factory ThemeModeChangedMessage.fromMap(Map map) => ThemeModeChangedMessage(
        isDarkMode: map["isDarkMode"],
      );
}

class ThemeChangedMessage extends DesktopLyricMessage {
  final Color primary;
  final Color surfaceContainer;
  final Color onSurface;

  ThemeChangedMessage({
    required this.primary,
    required this.surfaceContainer,
    required this.onSurface,
  });

  ThemeChangedMessage.fromColorScheme(ColorScheme scheme)
      : primary = scheme.primary,
        surfaceContainer = scheme.surfaceContainer,
        onSurface = scheme.onSurface;

  @override
  Map toMap() => {
        "type": "ThemeChangedMessage",
        "primary": primary.value,
        "surfaceContainer": surfaceContainer.value,
        "onSurface": onSurface.value,
      };
  @override
  String toString() => json.encode(toMap());

  factory ThemeChangedMessage.fromMap(Map map) => ThemeChangedMessage(
        primary: Color(map["primary"]),
        surfaceContainer: Color(map["surfaceContainer"]),
        onSurface: Color(map["onSurface"]),
      );
}

class NowPlayingChangedMessage extends DesktopLyricMessage {
  final String title;
  final String artist;
  final String album;

  NowPlayingChangedMessage({
    required this.title,
    required this.artist,
    required this.album,
  });

  @override
  Map toMap() => {
        "type": "NowPlayingChangedMessage",
        "title": title,
        "artist": artist,
        "album": album,
      };
  @override
  String toString() => json.encode(toMap());

  factory NowPlayingChangedMessage.fromMap(Map map) => NowPlayingChangedMessage(
      title: map["title"], artist: map["artist"], album: map["album"]);
}

class LyricLineMessage extends DesktopLyricMessage {
  final String content;
  final String? translation;
  final Duration length;
  LyricLineMessage({
    required this.content,
    this.translation,
    required this.length,
  });
  @override
  Map toMap() => {
        "type": "LyricLineMessage",
        "content": content,
        "translation": translation,
        "length": length.inMilliseconds,
      };
  @override
  String toString() => json.encode(toMap());

  factory LyricLineMessage.fromMap(Map map) => LyricLineMessage(
        content: map["content"],
        translation: map["translation"],
        length: Duration(milliseconds: map["length"]),
      );
}
