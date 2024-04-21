import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:github/github.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

class AppSettings {
  static final github = GitHub();
  static const String version = "1.0.0";
  Brightness themeMode = Brightness.light;
  bool dynamicTheme = true;
  int defaultTheme = 4290545753;
  List artistSeparator = ["/", "、"];
  bool localLyricFirst = true;
  Size windowSize = const Size(1280, 720);

  late String artistSplitPattern = artistSeparator.join("|");

  static final AppSettings _instance = AppSettings._();

  static AppSettings get instance => _instance;

  AppSettings._();

  static Future<void> readFromJson() async {
    final supportPath = (await getApplicationSupportDirectory()).path;
    final settingsPath = "$supportPath\\settings.json";

    final settingsStr = File(settingsPath).readAsStringSync();
    Map settingsMap = json.decode(settingsStr);

    _instance.themeMode =
        settingsMap["ThemeMode"] == 0 ? Brightness.light : Brightness.dark;
    _instance.dynamicTheme = settingsMap["DynamicTheme"] == 1 ? true : false;
    _instance.defaultTheme = settingsMap["DefaultTheme"];
    _instance.artistSeparator = settingsMap["ArtistSeparator"];
    _instance.artistSplitPattern = _instance.artistSeparator.join("|");
    
    final llf = settingsMap["LocalLyricFirst"];
    if (llf != null) {
      _instance.localLyricFirst = llf == 1 ? true : false;
    }

    final sizeStr = settingsMap["WindowSize"];
    if (sizeStr != null) {
      final sizeStrs = (sizeStr as String).split(",");
      _instance.windowSize = Size(double.tryParse(sizeStrs[0]) ?? 1280,
          double.tryParse(sizeStrs[1]) ?? 720);
    }
  }

  Future<void> saveSettings() async {
    final currSize = await windowManager.getSize();
    final settingsMap = {
      "ThemeMode": themeMode == Brightness.light ? 0 : 1,
      "DynamicTheme": dynamicTheme ? 1 : 0,
      "DefaultTheme": defaultTheme,
      "ArtistSeparator": artistSeparator,
      "LocalLyricFirst": localLyricFirst ? 1 : 0,
      "WindowSize":
          "${currSize.width.toStringAsFixed(1)},${currSize.height.toStringAsFixed(1)}"
    };

    final settingsStr = json.encode(settingsMap);
    final supportPath = (await getApplicationSupportDirectory()).path;
    final settingsPath = "$supportPath\\settings.json";
    File(settingsPath).writeAsStringSync(settingsStr);
  }
}
