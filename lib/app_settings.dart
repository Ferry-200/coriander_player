import 'dart:convert';
import 'dart:io';
import 'package:coriander_player/src/rust/api/system_theme.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:github/github.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

/// 把旧的 app data 目录（如果存在）移到新的目录
/// 只在新 app data 目录没有数据时进行
/// 从 C:\Users\$username\AppData\Roaming\com.example\coriander_player 移到 C:\Users\$username\Documents\coriander_player
Future<void> migrateAppData() async {
  try {
    final newAppDataDir = await getAppDataDir();
    if (newAppDataDir.listSync().isNotEmpty) return;

    final oldAppDataDir = await getApplicationSupportDirectory();

    if (oldAppDataDir.existsSync()) {
      final datas = oldAppDataDir.listSync();
      for (var item in datas) {
        final oldDataFile = File(item.path);
        oldDataFile.copySync(
          path.join(newAppDataDir.path, path.basename(item.path)),
        );
      }
    }
  } catch (err, trace) {
    LOGGER.e(err, stackTrace: trace);
  }
}

Future<Directory> getAppDataDir() async {
  final dir = await getApplicationDocumentsDirectory();
  return Directory(path.join(dir.path, "coriander_player"))
      .create(recursive: true);
}

class AppSettings {
  static final github = GitHub();
  static const String version = "1.5.1";

  /// 主题模式：亮 / 暗
  ThemeMode themeMode = getWindowsThemeMode();

  /// 启动时 / 封面主题色不适合当主题时的主题
  int defaultTheme = getWindowsTheme();

  /// 跟随歌曲封面的动态主题
  bool dynamicTheme = true;

  /// 跟随系统主题色
  bool useSystemTheme = true;

  /// 跟随系统主题模式
  bool useSystemThemeMode = true;

  List artistSeparator = ["/", "、"];

  /// 歌词来源：true，本地优先；false，在线优先
  bool localLyricFirst = true;
  Size windowSize = const Size(1280, 756);
  bool isWindowMaximized = false;

  /// 最小化到系统托盘
  bool minimizeToTray = true;

  String? fontFamily;
  String? fontPath;

  late String artistSplitPattern = artistSeparator.join("|");

  static final AppSettings _instance = AppSettings._();

  static AppSettings get instance => _instance;

  static ThemeMode getWindowsThemeMode() {
    final systemTheme = SystemTheme.getSystemTheme();

    final isDarkMode = (((5 * systemTheme.fore.$3) +
            (2 * systemTheme.fore.$2) +
            systemTheme.fore.$4) >
        (8 * 128));
    return isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  static int getWindowsTheme() {
    final systemTheme = SystemTheme.getSystemTheme();
    return Color.fromARGB(
      systemTheme.accent.$1,
      systemTheme.accent.$2,
      systemTheme.accent.$3,
      systemTheme.accent.$4,
    ).value;
  }

  AppSettings._();

  static Future<void> _readFromJson_old(Map settingsMap) async {
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
          settingsMap["ThemeMode"] == 0 ? ThemeMode.light : ThemeMode.dark;
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
          double.tryParse(sizeStrs[1]) ?? 756);
    }

    final isMaximized = settingsMap["IsWindowMaximized"];
    if (isMaximized != null) {
      _instance.isWindowMaximized = isMaximized == 1;
    }
  }

  static Future<void> readFromJson() async {
    try {
      final supportPath = (await getAppDataDir()).path;
      final settingsPath = "$supportPath\\settings.json";

      final settingsStr = File(settingsPath).readAsStringSync();
      Map settingsMap = json.decode(settingsStr);

      if (settingsMap["Version"] == null) {
        return _readFromJson_old(settingsMap);
      }

      final ust = settingsMap["UseSystemTheme"];
      if (ust != null) {
        _instance.useSystemTheme = ust;
      }

      final ustm = settingsMap["UseSystemThemeMode"];
      if (ustm != null) {
        _instance.useSystemThemeMode = ustm;
      }

      if (!_instance.useSystemTheme) {
        _instance.defaultTheme = settingsMap["DefaultTheme"];
      }
      if (!_instance.useSystemThemeMode) {
        _instance.themeMode = (settingsMap["ThemeMode"] ?? false)
            ? ThemeMode.dark
            : ThemeMode.light;
      }

      final dt = settingsMap["DynamicTheme"];
      if (dt != null) {
        _instance.dynamicTheme = dt;
      }

      final as = settingsMap["ArtistSeparator"];
      if (as != null) {
        _instance.artistSeparator = as;
        _instance.artistSplitPattern = _instance.artistSeparator.join("|");
      }

      final llf = settingsMap["LocalLyricFirst"];
      if (llf != null) {
        _instance.localLyricFirst = llf;
      }

      final sizeStr = settingsMap["WindowSize"];
      if (sizeStr != null) {
        final sizeStrs = (sizeStr as String).split(",");
        _instance.windowSize = Size(double.tryParse(sizeStrs[0]) ?? 1280,
            double.tryParse(sizeStrs[1]) ?? 756);
      }

      final isMaximized = settingsMap["IsWindowMaximized"];
      if (isMaximized != null) {
        _instance.isWindowMaximized = isMaximized;
      }

      final mtt = settingsMap["MinimizeToTray"];
      if (mtt != null) {
        _instance.minimizeToTray = mtt;
      }

      final ff = settingsMap["FontFamily"];
      final fp = settingsMap["FontPath"];
      if (ff != null) {
        _instance.fontFamily = ff;
        _instance.fontPath = fp;
      }
    } catch (err, trace) {
      LOGGER.e(err, stackTrace: trace);
    }
  }

  Future<void> saveSettings() async {
    try {
      final isMaximized = await windowManager.isMaximized();
      final isFullScreen = await windowManager.isFullScreen();
      final settingsMap = {
        "Version": version,
        "ThemeMode": themeMode == ThemeMode.dark,
        "DynamicTheme": dynamicTheme,
        "UseSystemTheme": useSystemTheme,
        "UseSystemThemeMode": useSystemThemeMode,
        "DefaultTheme": defaultTheme,
        "ArtistSeparator": artistSeparator,
        "LocalLyricFirst": localLyricFirst,
        "IsWindowMaximized": isMaximized,
        "MinimizeToTray": minimizeToTray,
        "FontFamily": fontFamily,
        "FontPath": fontPath,
      };

      // 只有在窗口不是最大化且不是全屏时才保存窗口尺寸
      // 这样windowSize始终保存的是窗口化时的尺寸
      Size sizeToSave = windowSize;
      if (!isMaximized && !isFullScreen) {
        sizeToSave = await windowManager.getSize();
      }
      settingsMap["WindowSize"] =
          "${sizeToSave.width.toStringAsFixed(1)},${sizeToSave.height.toStringAsFixed(1)}";

      final settingsStr = json.encode(settingsMap);
      final supportPath = (await getAppDataDir()).path;
      final settingsPath = "$supportPath\\settings.json";
      final output = await File(settingsPath).create(recursive: true);
      output.writeAsStringSync(settingsStr);
    } catch (err, trace) {
      LOGGER.e(err, stackTrace: trace);
    }
  }
}
