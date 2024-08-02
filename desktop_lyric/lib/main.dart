import 'package:desktop_lyric/component/desktop_lyric_body.dart';
import 'package:desktop_lyric/player_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  PlayerStates.initWithArgs(args);

  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 122),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    alwaysOnTop: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setAsFrameless();
    await windowManager.show();
  });

  runApp(const DesktopLyricApp());
}

class DesktopLyricApp extends StatelessWidget {
  const DesktopLyricApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: PlayerStates.instance.themeMode,
      builder: (context, themeMode, _) => ValueListenableProvider.value(
        value: PlayerStates.instance.themeChanged,
        child: MaterialApp(
          themeMode: themeMode,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          supportedLocales: supportedLocales,
          home: const DesktopLyricBody(),
        ),
      ),
    );
  }

  final supportedLocales = const [
    Locale.fromSubtags(languageCode: 'zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hans'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hans', countryCode: 'CN'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'TW'),
    Locale.fromSubtags(
        languageCode: 'zh', scriptCode: 'Hant', countryCode: 'HK'),
    Locale("en", "US"),
  ];
}
