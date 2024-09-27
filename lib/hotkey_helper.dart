import 'package:coriander_player/entry.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:go_router/go_router.dart';

class HotkeyHelper {
  static final Map<PhysicalKeyboardKey, void Function(HotKey)> _hotKeys = {
    PhysicalKeyboardKey.space: (_) {
      final playbackService = PlayService.instance.playbackService;
      final state = playbackService.playerState;
      if (state == PlayerState.playing) {
        playbackService.pause();
      } else if (state == PlayerState.completed) {
        playbackService.playAgain();
      } else {
        playbackService.start();
      }
    },
    PhysicalKeyboardKey.escape: (_) {
      if (ROUTER_KEY.currentContext?.canPop() == true) {
        ROUTER_KEY.currentContext?.pop();
      }
    }
  };

  static void registerHotKeys() {
    for (var item in _hotKeys.entries) {
      hotKeyManager.register(
        HotKey(key: item.key, scope: HotKeyScope.inapp),
        keyDownHandler: item.value,
      );
    }
  }

  static void unregisterAll() => hotKeyManager.unregisterAll();
}
