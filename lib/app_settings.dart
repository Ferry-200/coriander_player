import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:github/github.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:windows_ui/windows_ui.dart' as winui;

Color getWindowsAccentColor() {
  final c = winui.UISettings().getColorValue(winui.UIColorType.accent);
  return Color.fromARGB(c.a, c.r, c.g, c.b);
}

Brightness getWindowsColorMode() {
  final fore = winui.UISettings().getColorValue(winui.UIColorType.foreground);
  final isDarkMode = (((5 * fore.g) + (2 * fore.r) + fore.b) > (8 * 128));
  return isDarkMode ? Brightness.dark : Brightness.light;
}

class AppSettings {
  static final github = GitHub();
  static const String version = "1.0.0";

  /// 主题模式：亮 / 暗
  Brightness themeMode = getWindowsColorMode();

  /// 启动时 / 封面主题色不适合当主题时的主题
  int defaultTheme = getWindowsAccentColor().value;

  /// 跟随歌曲封面的动态主题
  bool dynamicTheme = true;

  /// 跟随系统主题色
  bool useSystemTheme = true;

  /// 跟随系统主题模式
  bool useSystemThemeMode = true;

  List artistSeparator = ["/", "、"];

  /// 歌词来源：true，本地优先；false，在线优先
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

    final ust = settingsMap["UseSystemTheme"];
    if (ust != null) {
      _instance.useSystemTheme = ust == 1 ? true : false;
    }

    final ustm = settingsMap["UseSystemThemeMode"];
    if (ustm != null) {
      _instance.useSystemThemeMode = ustm == 1 ? true : false;
    }

    if (!_instance.useSystemTheme) {
      _instance.defaultTheme = settingsMap["DefaultTheme"];
    }
    if (!_instance.useSystemThemeMode) {
      _instance.themeMode =
          settingsMap["ThemeMode"] == 0 ? Brightness.light : Brightness.dark;
    }

    _instance.dynamicTheme = settingsMap["DynamicTheme"] == 1 ? true : false;
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
      "UseSystemTheme": useSystemTheme ? 1 : 0,
      "UseSystemThemeMode": useSystemThemeMode ? 1 : 0,
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
