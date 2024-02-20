import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:path_provider/path_provider.dart';

class AppSettings {
  Brightness themeMode = Brightness.light;
  bool dynamicTheme = true;
  int defaultTheme = 4290545753;
  List artistSeparator = ["/", "、"];
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
  }

  Future<void> saveSettings() async {
    final settingsMap = {
      "ThemeMode": themeMode == Brightness.light ? 0 : 1,
      "DynamicTheme": dynamicTheme ? 1 : 0,
      "DefaultTheme": defaultTheme,
      "ArtistSeparator": artistSeparator,
    };

    final settingsStr = json.encode(settingsMap);
    final supportPath = (await getApplicationSupportDirectory()).path;
    final settingsPath = "$supportPath\\settings.json";
    File(settingsPath).writeAsStringSync(settingsStr);
  }
}
