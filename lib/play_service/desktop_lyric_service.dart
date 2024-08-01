import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/play_service/playback_service.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';

import 'package:desktop_lyric/message.dart';

class DesktopLyricService extends ChangeNotifier {
  final PlayService playService;
  DesktopLyricService(this.playService);

  PlaybackService get _playbackService => playService.playbackService;

  Future<Process?> desktopLyric = Future.value(null);
  StreamSubscription? _desktopLyricSubscription;

  Future<void> startDesktopLyric() async {
    final desktopLyricPath = path.join(
      path.dirname(Platform.resolvedExecutable),
      "desktop_lyric",
      'desktop_lyric.exe',
    );
    desktopLyric = Process.start(desktopLyricPath, []);

    final result = await desktopLyric;

    final transformedStream = result?.stdout.transform(utf8.decoder);
    _desktopLyricSubscription = transformedStream?.listen(
      (event) {
        try {
          final Map messageMap = json.decode(event);
          final String messageType = messageMap["type"];
          if (messageType == "PlayerActionMessage") {
            switch (PlayerActionMessage.fromMap(messageMap).action) {
              case null:
                break;
              case PlayerAction.PAUSE:
                _playbackService.pause();
                break;
              case PlayerAction.START:
                _playbackService.start();
                break;
              case PlayerAction.PREVIOUS_AUDIO:
                _playbackService.lastAudio();
                break;
              case PlayerAction.NEXT_AUDIO:
                _playbackService.nextAudio();
                break;
              case PlayerAction.CLOSE_DESKTOP_LYRIC:
                killDesktopLyric();
                break;
            }
          }
        } catch (_) {}
      },
    );

    notifyListeners();
  }

  Future<bool> get canSendMessage => desktopLyric.then(
        (value) => value != null,
      );

  void sendMessage(DesktopLyricMessage message) {
    desktopLyric.then((value) {
      value?.stdin.write(message);
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
}
