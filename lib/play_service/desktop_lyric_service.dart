import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/play_service/playback_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:desktop_lyric/message.dart' as dl;

class DesktopLyricService extends ChangeNotifier {
  final PlayService playService;
  DesktopLyricService(this.playService);

  PlaybackService get _playbackService => playService.playbackService;

  Future<Process?> desktopLyric = Future.value(null);
  StreamSubscription? _desktopLyricSubscription;

  bool isLocked = false;

  Future<void> startDesktopLyric() async {
    final desktopLyricPath = path.join(
      path.dirname(Platform.resolvedExecutable),
      "desktop_lyric",
      'desktop_lyric.exe',
    );

    final nowPlaying = _playbackService.nowPlaying;
    final currScheme = ThemeProvider.instance.currScheme;
    final isDarkMode = ThemeProvider.instance.themeMode == ThemeMode.dark;
    desktopLyric = Process.start(desktopLyricPath, [
      json.encode(dl.InitArgsMessage(
        _playbackService.playerState == PlayerState.playing,
        nowPlaying?.title ?? "无",
        nowPlaying?.artist ?? "无",
        nowPlaying?.album ?? "无",
        isDarkMode,
        currScheme.primary.value,
        currScheme.surfaceContainer.value,
        currScheme.onSurface.value,
      ).toJson())
    ]);

    final process = await desktopLyric;

    process?.stderr.transform(utf8.decoder).listen((event) {
      print(event);
    });

    _desktopLyricSubscription = process?.stdout.transform(utf8.decoder).listen(
      (event) {
        try {
          final Map messageMap = json.decode(event);
          print(messageMap);
          final String messageType = messageMap["type"];
          final messageContent = messageMap["message"] as Map<String, dynamic>;
          if (messageType ==
              dl.DesktopLyricMessageType.ControlEventMessage.name) {
            final controlEvent =
                dl.ControlEventMessage.fromJson(messageContent);
            switch (controlEvent.event) {
              case dl.ControlEvent.pause:
                _playbackService.pause();
                break;
              case dl.ControlEvent.start:
                _playbackService.start();
                break;
              case dl.ControlEvent.previousAudio:
                _playbackService.lastAudio();
                break;
              case dl.ControlEvent.nextAudio:
                _playbackService.nextAudio();
                break;
              case dl.ControlEvent.lock:
                isLocked = true;
                notifyListeners();
                break;
              case dl.ControlEvent.close:
                killDesktopLyric();
                break;
            }
          }
        } catch (err, stack) {
          print(err);
          print(stack);
        }
      },
    );

    notifyListeners();
  }

  Future<bool> get canSendMessage => desktopLyric.then(
        (value) => value != null,
      );

  void sendMessage(dl.DesktopLyricMessageType type, dl.Message message) {
    desktopLyric.then((value) {
      value?.stdin.write(type.buildMessageJson(message));
    });
  }

  void killDesktopLyric() {
    desktopLyric.then((value) {
      value?.kill();
      desktopLyric = Future.value(null);

      _desktopLyricSubscription?.cancel();
      _desktopLyricSubscription = null;

      notifyListeners();
    });
  }

  void sendUnlockMessage() {
    sendMessage(
      dl.DesktopLyricMessageType.UnlockMessage,
      const dl.UnlockMessage(),
    );
    isLocked = false;
    notifyListeners();
  }

  void sendThemeModeMessage(bool darkMode) {
    sendMessage(
      dl.DesktopLyricMessageType.ThemeModeChangedMessage,
      dl.ThemeModeChangedMessage(darkMode),
    );
  }

  void sendThemeMessage(ColorScheme scheme) {
    sendMessage(
      dl.DesktopLyricMessageType.ThemeChangedMessage,
      dl.ThemeChangedMessage(
        scheme.primary.value,
        scheme.surfaceContainer.value,
        scheme.onSurface.value,
      ),
    );
  }

  void sendPlayerStateMessage(bool isPlaying) {
    sendMessage(
      dl.DesktopLyricMessageType.PlayerStateChangedMessage,
      dl.PlayerStateChangedMessage(isPlaying),
    );
  }

  void sendNowPlayingMessage(Audio nowPlaying) {
    sendMessage(
      dl.DesktopLyricMessageType.NowPlayingChangedMessage,
      dl.NowPlayingChangedMessage(
        nowPlaying.title,
        nowPlaying.artist,
        nowPlaying.album,
      ),
    );
  }

  void sendLyricLineMessage(LyricLine line) {
    if (line is SyncLyricLine) {
      sendMessage(
        dl.DesktopLyricMessageType.LyricLineChangedMessage,
        dl.LyricLineChangedMessage(line.content, line.length, line.translation),
      );
    } else if (line is LrcLine) {
      final splitted = line.content.split("┃");
      final content = splitted.first;
      final translation = splitted.length > 1 ? splitted[1] : null;
      sendMessage(
        dl.DesktopLyricMessageType.LyricLineChangedMessage,
        dl.LyricLineChangedMessage(content, line.length, translation),
      );
    }
  }
}
