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
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;

import 'package:desktop_lyric/message.dart' as msg;

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
      json.encode(msg.InitArgsMessage(
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
      LOGGER.e("[desktop lyric] $event");
    });

    _desktopLyricSubscription = process?.stdout.transform(utf8.decoder).listen(
      (event) {
        try {
          final Map messageMap = json.decode(event);
          final String messageType = messageMap["type"];
          final messageContent = messageMap["message"] as Map<String, dynamic>;
          if (messageType ==
              msg.getMessageTypeName<msg.ControlEventMessage>()) {
            final controlEvent =
                msg.ControlEventMessage.fromJson(messageContent);
            switch (controlEvent.event) {
              case msg.ControlEvent.pause:
                _playbackService.pause();
                break;
              case msg.ControlEvent.start:
                _playbackService.start();
                break;
              case msg.ControlEvent.previousAudio:
                _playbackService.lastAudio();
                break;
              case msg.ControlEvent.nextAudio:
                _playbackService.nextAudio();
                break;
              case msg.ControlEvent.lock:
                isLocked = true;
                notifyListeners();
                break;
              case msg.ControlEvent.close:
                killDesktopLyric();
                break;
            }
          }
        } catch (err) {
          LOGGER.e("[desktop lyric] $err");
        }
      },
    );

    notifyListeners();
  }

  Future<bool> get canSendMessage => desktopLyric.then(
        (value) => value != null,
      );

  void sendMessage(msg.Message message) {
    desktopLyric.then((value) {
      value?.stdin.write(message.buildMessageJson());
    }).catchError((err, trace) {
      LOGGER.e(err, stackTrace: trace);
    });
  }

  void killDesktopLyric() {
    desktopLyric.then((value) {
      value?.kill();
      desktopLyric = Future.value(null);

      _desktopLyricSubscription?.cancel();
      _desktopLyricSubscription = null;

      notifyListeners();
    }).catchError((err, trace) {
      LOGGER.e(err, stackTrace: trace);
    });
  }

  void sendUnlockMessage() {
    sendMessage(const msg.UnlockMessage());
    isLocked = false;
    notifyListeners();
  }

  void sendThemeModeMessage(bool darkMode) {
    sendMessage(msg.ThemeModeChangedMessage(darkMode));
  }

  void sendThemeMessage(ColorScheme scheme) {
    sendMessage(msg.ThemeChangedMessage(
      scheme.primary.value,
      scheme.surfaceContainer.value,
      scheme.onSurface.value,
    ));
  }

  void sendPlayerStateMessage(bool isPlaying) {
    sendMessage(msg.PlayerStateChangedMessage(isPlaying));
  }

  void sendNowPlayingMessage(Audio nowPlaying) {
    sendMessage(msg.NowPlayingChangedMessage(
      nowPlaying.title,
      nowPlaying.artist,
      nowPlaying.album,
    ));
  }

  void sendLyricLineMessage(LyricLine line) {
    if (line is SyncLyricLine) {
      sendMessage(msg.LyricLineChangedMessage(
        line.content,
        line.length,
        line.translation,
      ));
    } else if (line is LrcLine) {
      final splitted = line.content.split("┃");
      final content = splitted.first;
      final translation = splitted.length > 1 ? splitted[1] : null;
      sendMessage(msg.LyricLineChangedMessage(
        content,
        line.length,
        translation,
      ));
    }
  }
}
