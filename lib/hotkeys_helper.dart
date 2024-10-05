import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:go_router/go_router.dart';

class HotkeysHelper {
  static final Map<HotKey, void Function(HotKey)> _hotKeys = {
    HotKey(key: PhysicalKeyboardKey.space, scope: HotKeyScope.inapp): (_) {
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
    HotKey(key: PhysicalKeyboardKey.escape, scope: HotKeyScope.inapp): (_) {
      final routerContext = ROUTER_KEY.currentContext;
      if (routerContext == null) return;

      // 先关闭弹窗，再返回上一级页面
      final navigator = Navigator.maybeOf(routerContext);
      if (navigator?.canPop() == true) {
        navigator?.pop();
      } else if (ROUTER_KEY.currentContext?.canPop() == true) {
        ROUTER_KEY.currentContext?.pop();
      }
    },
    HotKey(
      key: PhysicalKeyboardKey.arrowLeft,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    ): (_) {
      PlayService.instance.playbackService.lastAudio();
    },
    HotKey(
      key: PhysicalKeyboardKey.arrowRight,
      modifiers: [HotKeyModifier.control],
      scope: HotKeyScope.inapp,
    ): (_) {
      PlayService.instance.playbackService.nextAudio();
    },
  };

  static void registerHotKeys() {
    for (var item in _hotKeys.entries) {
      hotKeyManager.register(
        item.key,
        keyDownHandler: item.value,
      );
    }
  }

  static Future<void> unregisterAll() => hotKeyManager.unregisterAll();

  static Future<void> onFocusChanges(focus) async {
    if (focus) {
      await unregisterAll();
    } else {
      registerHotKeys();
    }
  }
}
