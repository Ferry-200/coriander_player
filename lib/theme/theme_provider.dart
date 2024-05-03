import 'dart:async';

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/src/rust/api/system_theme.dart';
import 'package:coriander_player/theme/color_palette.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ColorPalette palette = ColorPalette.fromSeed(
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
      palette = ColorPalette.fromSeed(seedValue: seed, brightness: themeMode);
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
    this.palette = palette;
    notifyListeners();
  }

  void toggleThemeMode() {
    palette = palette.brightness == Brightness.light
        ? ColorPalette.fromSeed(
            seedValue: palette.seed,
            brightness: Brightness.dark,
          )
        : ColorPalette.fromSeed(
            seedValue: palette.seed,
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
          brightness: palette.brightness,
        ).then(
          (value) {
            palette = value;
            notifyListeners();
          },
        );
      }
    });
  }

  ButtonStyle get primaryButtonStyle => ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(palette.primary),
        foregroundColor: MaterialStatePropertyAll(palette.onPrimary),
        fixedSize: const MaterialStatePropertyAll(Size.fromHeight(40.0)),
        overlayColor:
            MaterialStatePropertyAll(palette.onPrimary.withOpacity(0.08)),
      );

  ButtonStyle get secondaryButtonStyle => ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(palette.secondaryContainer),
        foregroundColor: MaterialStatePropertyAll(palette.onSecondaryContainer),
        fixedSize: const MaterialStatePropertyAll(Size.fromHeight(40.0)),
        overlayColor: MaterialStatePropertyAll(
            palette.onSecondaryContainer.withOpacity(0.08)),
      );

  ButtonStyle get primaryIconButtonStyle => ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(palette.primary),
        foregroundColor: MaterialStatePropertyAll(palette.onPrimary),
        overlayColor: MaterialStatePropertyAll(
          palette.onPrimary.withOpacity(0.08),
        ),
      );

  ButtonStyle get secondaryIconButtonStyle => ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(palette.secondaryContainer),
        foregroundColor: MaterialStatePropertyAll(palette.onSecondaryContainer),
        overlayColor: MaterialStatePropertyAll(
          palette.onSecondaryContainer.withOpacity(0.08),
        ),
      );

  ButtonStyle get menuItemStyle => ButtonStyle(
        backgroundColor: MaterialStatePropertyAll(palette.secondaryContainer),
        foregroundColor: MaterialStatePropertyAll(palette.onSecondaryContainer),
        padding: const MaterialStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 16.0),
        ),
        overlayColor: MaterialStatePropertyAll(
          palette.onSecondaryContainer.withOpacity(0.08),
        ),
      );

  MenuStyle get menuStyleWithFixedSize => MenuStyle(
        backgroundColor: MaterialStatePropertyAll(palette.secondaryContainer),
        surfaceTintColor: MaterialStatePropertyAll(palette.secondaryContainer),
        shape: MaterialStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        )),
        fixedSize: const MaterialStatePropertyAll(Size.fromWidth(149.0)),
      );

  MenuStyle get menuStyle => MenuStyle(
        shape: MaterialStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        backgroundColor: MaterialStatePropertyAll(palette.surfaceContainer),
        surfaceTintColor: MaterialStatePropertyAll(palette.surfaceContainer),
      );

  InputDecoration inputDecoration(String labelText) => InputDecoration(
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: palette.outline, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
        labelText: labelText,
        labelStyle: TextStyle(color: palette.onSurfaceVariant),
        floatingLabelStyle: TextStyle(color: palette.primary),
        focusColor: palette.primary,
      );
}
