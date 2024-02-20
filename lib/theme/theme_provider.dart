import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/theme/color_palette.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ColorPalette palette = ColorPalette.fromSeed(
    seedValue: AppSettings.instance.defaultTheme,
    brightness: AppSettings.instance.themeMode,
  );

  static ThemeProvider? _instance;

  ThemeProvider._();

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
}
