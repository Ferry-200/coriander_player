// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';

abstract class DesktopLyricMessage {
  DesktopLyricMessage();

  Map toMap() => {"type": "DesktopLyricMessage"};
}

enum PlayerAction {
  /// 暂停，也表示歌曲暂停播放的状态。可以由播放器发送到桌面歌词，也可以反过来。
  PAUSE,

  /// 播放（resume），也表示歌曲播放中的状态。可以由播放器发送到桌面歌词，也可以反过来。
  START,

  /// 上一曲。只可以由桌面歌词发送到播放器。
  PREVIOUS_AUDIO,

  /// 下一曲。只可以由桌面歌词发送到播放器
  NEXT_AUDIO,

  /// 关闭桌面歌词。只可以由桌面歌词发送到播放器
  CLOSE_DESKTOP_LYRIC;

  static PlayerAction? fromName(String name) {
    for (var item in PlayerAction.values) {
      if (item.name == name) return item;
    }
    return null;
  }
}

/// 播放器行为。可以由播放器发送到桌面歌词，也可以反过来。
/// 
/// 当播放器每一次暂停或者开始播放歌曲时，都应该发送此消息。
/// 
/// 示例如下，如果这个消息由播放器发送给桌面歌词，就是更新桌面歌词的状态为暂停；
/// 如果是由桌面歌词发送给播放器，就是请求播放器暂停音乐。
/// ```json
/// {
///   "type": "PlayerActionMessage",
///   "action": "PAUSE"
/// }
/// ```
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

/// 主题模式更新信息。只可以由播放器发送到桌面歌词。
/// 
/// 可以在播放器启用夜间模式时通知桌面歌词切换到夜间模式。
/// 
/// 示例如下，这样要求桌面歌词切换到夜间模式。
/// ```json
/// {
///   "type": "ThemeModeChangedMessage",
///   "isDarkMode": true
/// }
/// ```
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

/// 主题更新信息。只可以由播放器发送到桌面歌词。
/// 
/// primary: 用于歌曲信息和歌词文本
/// surfaceContainer: 用于鼠标悬停在桌面歌词上时的背景颜色
/// onSurface: 用于控件颜色（鼠标悬停在桌面歌词上时的控件）
/// 
/// 如果播放器可以更改主题色，可以通过这个消息让桌面歌词的主题与之一致。
/// 
/// 示例如下，这样要求桌面歌词使用指定主题。
/// 
/// ```json
/// {
///   "type": "ThemeChangedMessage",
///   "primary": 0xFFFF9000,
///   "surfaceContainer": 0xFFFF9000,
///   "onSurface": 0xFFFF9000,
/// }
/// ```
/// For example, to get a fully opaque orange, you would use const Color(0xFFFF9000)
/// (FF for the alpha, FF for the red, 90 for the green, and 00 for the blue)。
/// 
/// 这里应该要把 0xFFFF9000 当作 int 来构造 json
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

/// 正在播放曲目更新信息。只可以由播放器发送到桌面歌词。
/// 
/// 在每次开始播放曲目时发送。
/// 
/// 示例如下，这样要求桌面歌词显示指定的正在播放曲目信息。
/// ```json
/// {
///   "type": "NowPlayingChangedMessage",
///   "title": "title",
///   "artist": "artist",
///   "album": "album",
/// }
/// ```
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

/// 当前歌词行更新信息。只可以由播放器发送到桌面歌词。
/// 
/// content: 歌词内容，String
/// translation: 翻译，String（也可为 null）
/// length: 当前行持续时间（以 millisecond 计）。如果指定，桌面歌词会在歌词长度超出区域时在 length 指定时间内滚动展示整句歌词。
/// 
/// 在当前歌词行更新时发送。
/// 
/// 示例如下，这样要求桌面歌词显示指定的歌词。
/// ```json
/// {
///   "type": "LyricLineMessage",
///   "content": "宙舞う埃がキラキラ反射してる",
///   "translation": "宛若在空中飞舞般 反射着光芒" / null,
///   "length": 11890,
/// }
/// ```
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
