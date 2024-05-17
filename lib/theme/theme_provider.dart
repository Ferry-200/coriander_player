import 'dart:async';

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/src/rust/api/system_theme.dart';
import 'package:coriander_player/theme/color_palette.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ColorPalette scheme = ColorPalette.fromSeed(
    seedValue: AppSettings.instance.defaultTheme,
    brightness: AppSettings.instance.themeMode,
  );

  static ThemeProvider? _instance;

  late StreamSubscription<SystemTheme> _systemThemeChangedStreamSub;
  ThemeProvider._() {
    _systemThemeChangedStreamSub =
        SystemTheme.onSystemThemeChanged().listen((event) {
      final isDarkMode =
          (((5 * event.fore.$3) + (2 * event.fore.$2) + event.fore.$4) >
              (8 * 128));
      final themeMode = isDarkMode ? Brightness.dark : Brightness.light;
      final seed = Color.fromARGB(
        event.accent.$1,
        event.accent.$2,
        event.accent.$3,
        event.accent.$4,
      ).value;
      scheme = ColorPalette.fromSeed(seedValue: seed, brightness: themeMode);
      notifyListeners();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _systemThemeChangedStreamSub.cancel();
  }

  static ThemeProvider get instance {
    _instance ??= ThemeProvider._();
    return _instance!;
  }

  void changeTheme(ColorPalette palette) {
    this.scheme = palette;
    notifyListeners();
  }

  void toggleThemeMode() {
    scheme = scheme.brightness == Brightness.light
        ? ColorPalette.fromSeed(
            seedValue: scheme.seed,
            brightness: Brightness.dark,
          )
        : ColorPalette.fromSeed(
            seedValue: scheme.seed,
            brightness: Brightness.light,
          );
    notifyListeners();
  }

  void setPalleteFromAudio(Audio audio) async {
    if (!AppSettings.instance.dynamicTheme) return;

    audio.cover.then((image) {
      if (image != null) {
        ColorPalette.fromImageProvider(
          provider: image,
          brightness: scheme.brightness,
        ).then(
          (value) {
            scheme = value;
            notifyListeners();
          },
        );
      }
    });
  }

  ButtonStyle get primaryButtonStyle => ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.primary),
        foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
        fixedSize: const WidgetStatePropertyAll(Size.fromHeight(40.0)),
        overlayColor:
            WidgetStatePropertyAll(scheme.onPrimary.withOpacity(0.08)),
      );

  ButtonStyle get secondaryButtonStyle => ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
        foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
        fixedSize: const WidgetStatePropertyAll(Size.fromHeight(40.0)),
        overlayColor: WidgetStatePropertyAll(
            scheme.onSecondaryContainer.withOpacity(0.08)),
      );

  ButtonStyle get primaryIconButtonStyle => ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.primary),
        foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
        overlayColor: WidgetStatePropertyAll(
          scheme.onPrimary.withOpacity(0.08),
        ),
      );

  ButtonStyle get secondaryIconButtonStyle => ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
        foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
        overlayColor: WidgetStatePropertyAll(
          scheme.onSecondaryContainer.withOpacity(0.08),
        ),
      );

  ButtonStyle get menuItemStyle => ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
        foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        overlayColor: WidgetStatePropertyAll(
          scheme.onSecondaryContainer.withOpacity(0.08),
        ),
      );

  MenuStyle get menuStyleWithFixedSize => MenuStyle(
        backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
        surfaceTintColor: WidgetStatePropertyAll(scheme.secondaryContainer),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        )),
        fixedSize: const WidgetStatePropertyAll(Size.fromWidth(149.0)),
      );

  MenuStyle get menuStyle => MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        backgroundColor: WidgetStatePropertyAll(scheme.surfaceContainer),
        surfaceTintColor: WidgetStatePropertyAll(scheme.surfaceContainer),
      );

  InputDecoration inputDecoration(String labelText) => InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: scheme.primary),
        focusColor: scheme.primary,
      );
}
