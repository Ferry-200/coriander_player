import 'dart:io';

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/entry.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/src/rust/frb_generated.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'package:go_router/go_router.dart';

Future<void> initWindow() async {
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: const Size(507, 756),
    size: AppSettings.instance.windowSize,
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });
}

final Map<PhysicalKeyboardKey, void Function(HotKey)> _hotKeys = {
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

void registerHotKeys() {
  for (var item in _hotKeys.entries) {
    hotKeyManager.register(
      HotKey(key: item.key, scope: HotKeyScope.inapp),
      keyDownHandler: item.value,
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await RustLib.init();

  // For hot reload, `unregisterAll()` needs to be called.
  await hotKeyManager.unregisterAll();
  registerHotKeys();

  await migrateAppData();

  final supportPath = (await getAppDataDir()).path;
  if (File("$supportPath\\settings.json").existsSync()) {
    await AppSettings.readFromJson();
    final settings = AppSettings.instance;
    if (settings.fontFamily != null) {
      try {
        final fontLoader = FontLoader(settings.fontFamily!);

        fontLoader.addFont(
          File(settings.fontPath!).readAsBytes().then((value) {
            return ByteData.sublistView(value);
          }),
        );
        fontLoader.load().whenComplete(() {
          ThemeProvider.instance.changeFontFamily(settings.fontFamily!);
        });
      } catch (_) {}
    }
  }
  if (File("$supportPath\\app_preference.json").existsSync()) {
    await AppPreference.read();
  }
  final welcome = !File("$supportPath\\index.json").existsSync();

  await initWindow();

  runApp(Entry(welcome: welcome));
}
