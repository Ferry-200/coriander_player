import 'dart:io';

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/entry.dart';
import 'package:coriander_player/src/rust/frb_generated.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> initWindow() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = WindowOptions(
    minimumSize: const Size(500, 500),
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

Future<bool> judgeWelcome(String supportPath) async {
  final indexExists = File("$supportPath\\index.json").existsSync();
  final settingsExists = File("$supportPath\\settings.json").existsSync();
  return !indexExists || !settingsExists;
}

Future<void> main() async {
  await RustLib.init();
  final supportPath = (await getApplicationSupportDirectory()).path;
  if (File("$supportPath\\settings.json").existsSync()) {
    await AppSettings.readFromJson();
  }
  final welcome = await judgeWelcome(supportPath);
  await initWindow();

  runApp(Entry(welcome: welcome));
}
