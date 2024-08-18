import 'dart:io';

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/entry.dart';
import 'package:coriander_player/src/rust/frb_generated.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
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

Future<void> main() async {
  await RustLib.init();
  final supportPath = (await getApplicationSupportDirectory()).path;
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
