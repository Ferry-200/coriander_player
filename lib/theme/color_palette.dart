import 'dart:async';
import 'dart:typed_data';

import 'package:coriander_player/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart' hide Score;
import 'package:material_color_utilities/utils/math_utils.dart';
import 'dart:ui' as ui;

/// Material的ColorScheme没有[surfaceContainer]等属性。
/// 这些值可以由CorePalette的neutral.get方法获取。该类暴露了这些方法（ColorScheme不存储corePalette），易于拓展。
class ColorPalette {
  CorePalette palette;

  int seed;
  Brightness brightness;

  ui.Color surface;
  ui.Color primary;
  ui.Color secondary;

  ui.Color onSurface;
  ui.Color onSurfaceVariant;
  ui.Color onPrimary;
  ui.Color onSecondary;

  ui.Color surfaceContainer;
  ui.Color primaryContainer;
  ui.Color secondaryContainer;

  ui.Color onPrimaryContainer;
  ui.Color onSecondaryContainer;

  ui.Color outline;
  ui.Color outlineVariant;

  ui.Color error;
  ui.Color onError;

  ColorPalette(
    this.palette, {
    required this.seed,
    required this.brightness,
    required this.surface,
    required this.primary,
    required this.secondary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.onPrimary,
    required this.onSecondary,
    required this.surfaceContainer,
    required this.primaryContainer,
    required this.secondaryContainer,
    required this.onPrimaryContainer,
    required this.onSecondaryContainer,
    required this.outline,
    required this.outlineVariant,
    required this.error,
    required this.onError,
  });

  factory ColorPalette.fromSeed({
    int seedValue = 4290545753,
    Brightness brightness = Brightness.light,
  }) {
    final palette = CorePalette.of(seedValue);

    return brightness == Brightness.light
        ? ColorPalette(
            palette,
            seed: seedValue,
            brightness: Brightness.light,
            surface: ui.Color(palette.neutral.get(98)),
            primary: ui.Color(palette.primary.get(40)),
            secondary: ui.Color(palette.secondary.get(40)),
            onSurface: ui.Color(palette.neutral.get(10)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(30)),
            onPrimary: ui.Color(palette.primary.get(100)),
            onSecondary: ui.Color(palette.secondary.get(100)),
            surfaceContainer: ui.Color(palette.neutral.get(94)),
            primaryContainer: ui.Color(palette.primary.get(90)),
            secondaryContainer: ui.Color(palette.secondary.get(90)),
            onPrimaryContainer: ui.Color(palette.primary.get(10)),
            onSecondaryContainer: ui.Color(palette.secondary.get(10)),
            outline: ui.Color(palette.neutralVariant.get(50)),
            outlineVariant: ui.Color(palette.neutralVariant.get(80)),
            error: ui.Color(palette.error.get(40)),
            onError: ui.Color(palette.error.get(100)),
          )
        : ColorPalette(
            palette,
            seed: seedValue,
            brightness: Brightness.dark,
            surface: ui.Color(palette.neutral.get(6)),
            primary: ui.Color(palette.primary.get(80)),
            secondary: ui.Color(palette.secondary.get(80)),
            onSurface: ui.Color(palette.neutral.get(90)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(80)),
            onPrimary: ui.Color(palette.primary.get(20)),
            onSecondary: ui.Color(palette.secondary.get(20)),
            surfaceContainer: ui.Color(palette.neutral.get(12)),
            primaryContainer: ui.Color(palette.primary.get(30)),
            secondaryContainer: ui.Color(palette.secondary.get(30)),
            onPrimaryContainer: ui.Color(palette.primary.get(90)),
            onSecondaryContainer: ui.Color(palette.secondary.get(90)),
            outline: ui.Color(palette.neutralVariant.get(60)),
            outlineVariant: ui.Color(palette.neutralVariant.get(30)),
            error: ui.Color(palette.error.get(80)),
            onError: ui.Color(palette.error.get(20)),
          );
  }

  static Future<ColorPalette> fromImageProvider({
    required ImageProvider provider,
    Brightness brightness = Brightness.light,
  }) async {
    // Extract dominant colors from image.
    final QuantizerResult quantizerResult =
        await _extractColorsFromImageProvider(provider);
    final Map<int, int> colorToCount = quantizerResult.colorToCount.map(
      (int key, int value) => MapEntry<int, int>(_getArgbFromAbgr(key), value),
    );

    // Score colors for color scheme suitability.
    final List<int> scoredResults = Score.score(colorToCount, desired: 1);

    final palette = CorePalette.of(scoredResults.first);

    return brightness == Brightness.light
        ? ColorPalette(
            palette,
            seed: scoredResults.first,
            brightness: Brightness.light,
            surface: ui.Color(palette.neutral.get(98)),
            primary: ui.Color(palette.primary.get(40)),
            secondary: ui.Color(palette.secondary.get(40)),
            onSurface: ui.Color(palette.neutral.get(10)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(30)),
            onPrimary: ui.Color(palette.primary.get(100)),
            onSecondary: ui.Color(palette.secondary.get(100)),
            surfaceContainer: ui.Color(palette.neutral.get(94)),
            primaryContainer: ui.Color(palette.primary.get(90)),
            secondaryContainer: ui.Color(palette.secondary.get(90)),
            onPrimaryContainer: ui.Color(palette.primary.get(10)),
            onSecondaryContainer: ui.Color(palette.secondary.get(10)),
            outline: ui.Color(palette.neutralVariant.get(50)),
            outlineVariant: ui.Color(palette.neutralVariant.get(80)),
            error: ui.Color(palette.error.get(40)),
            onError: ui.Color(palette.error.get(100)),
          )
        : ColorPalette(
            palette,
            seed: scoredResults.first,
            brightness: Brightness.dark,
            surface: ui.Color(palette.neutral.get(6)),
            primary: ui.Color(palette.primary.get(80)),
            secondary: ui.Color(palette.secondary.get(80)),
            onSurface: ui.Color(palette.neutral.get(90)),
            onSurfaceVariant: ui.Color(palette.neutralVariant.get(80)),
            onPrimary: ui.Color(palette.primary.get(20)),
            onSecondary: ui.Color(palette.secondary.get(20)),
            surfaceContainer: ui.Color(palette.neutral.get(12)),
            primaryContainer: ui.Color(palette.primary.get(30)),
            secondaryContainer: ui.Color(palette.secondary.get(30)),
            onPrimaryContainer: ui.Color(palette.primary.get(90)),
            onSecondaryContainer: ui.Color(palette.secondary.get(90)),
            outline: ui.Color(palette.neutralVariant.get(60)),
            outlineVariant: ui.Color(palette.neutralVariant.get(30)),
            error: ui.Color(palette.error.get(80)),
            onError: ui.Color(palette.error.get(20)),
          );
  }

  /// Extracts bytes from an [ImageProvider] and returns a [QuantizerResult]
  /// containing the most dominant colors.
  /// copy from [ColorScheme]
  static Future<QuantizerResult> _extractColorsFromImageProvider(
      ImageProvider imageProvider) async {
    final ui.Image scaledImage = await _imageProviderToScaled(imageProvider);
    final ByteData? imageBytes = await scaledImage.toByteData();

    final QuantizerResult quantizerResult = await QuantizerCelebi().quantize(
      imageBytes!.buffer.asUint32List(),
      128,
      returnInputPixelToClusterPixel: true,
    );
    return quantizerResult;
  }

  /// Scale image size down to reduce computation time of color extraction.
  /// copy form [ColorScheme]
  static Future<ui.Image> _imageProviderToScaled(
      ImageProvider imageProvider) async {
    const double maxDimension = 112.0;
    final ImageStream stream = imageProvider.resolve(
        const ImageConfiguration(size: Size(maxDimension, maxDimension)));
    final Completer<ui.Image> imageCompleter = Completer<ui.Image>();
    late ImageStreamListener listener;
    late ui.Image scaledImage;
    Timer? loadFailureTimeout;

    listener = ImageStreamListener((ImageInfo info, bool sync) async {
      loadFailureTimeout?.cancel();
      stream.removeListener(listener);
      final ui.Image image = info.image;
      final int width = image.width;
      final int height = image.height;
      double paintWidth = width.toDouble();
      double paintHeight = height.toDouble();
      assert(width > 0 && height > 0);

      final bool rescale = width > maxDimension || height > maxDimension;
      if (rescale) {
        paintWidth =
            (width > height) ? maxDimension : (maxDimension / height) * width;
        paintHeight =
            (height > width) ? maxDimension : (maxDimension / width) * height;
      }
      final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      paintImage(
          canvas: canvas,
          rect: Rect.fromLTRB(0, 0, paintWidth, paintHeight),
          image: image,
          filterQuality: FilterQuality.none);

      final ui.Picture picture = pictureRecorder.endRecording();
      scaledImage =
          await picture.toImage(paintWidth.toInt(), paintHeight.toInt());
      imageCompleter.complete(info.image);
    }, onError: (Object exception, StackTrace? stackTrace) {
      stream.removeListener(listener);
      throw Exception('Failed to render image: $exception');
    });

    loadFailureTimeout = Timer(const Duration(seconds: 5), () {
      stream.removeListener(listener);
      imageCompleter.completeError(
          TimeoutException('Timeout occurred trying to load image'));
    });

    stream.addListener(listener);
    await imageCompleter.future;
    return scaledImage;
  }

  /// Converts AABBGGRR color int to AARRGGBB format.
  /// copy from [ColorScheme]
  static int _getArgbFromAbgr(int abgr) {
    const int exceptRMask = 0xFF00FFFF;
    const int onlyRMask = ~exceptRMask;
    const int exceptBMask = 0xFFFFFF00;
    const int onlyBMask = ~exceptBMask;
    final int r = (abgr & onlyRMask) >> 16;
    final int b = abgr & onlyBMask;
    return (abgr & exceptRMask & exceptBMask) | (b << 16) | r;
  }
}

/// copy from package:material_color_utilities Score
class _ArgbAndScore implements Comparable<_ArgbAndScore> {
  int argb;
  double score;

  _ArgbAndScore(this.argb, this.score);

  @override
  int compareTo(_ArgbAndScore other) {
    if (score > other.score) {
      return -1;
    } else if (score == other.score) {
      return 0;
    } else {
      return 1;
    }
  }
}

/// Given a large set of colors, remove colors that are unsuitable for a UI
/// theme, and rank the rest based on suitability.
///
/// Enables use of a high cluster count for image quantization, thus ensuring
/// colors aren't muddied, while curating the high cluster count to a much
///  smaller number of appropriate choices.
/// copy from package:material_color_utilities Score, 
/// change the default theme(Google blue) to user's default theme
class Score {
  static const _targetChroma = 48.0;
  static const _weightProportion = 0.7;
  static const _weightChromaAbove = 0.3;
  static const _weightChromaBelow = 0.1;
  static const _cutoffChroma = 5.0;
  static const _cutoffExcitedProportion = 0.01;

  /// Given a map with keys of colors and values of how often the color appears,
  /// rank the colors based on suitability for being used for a UI theme.
  ///
  /// [colorsToPopulation] is a map with keys of colors and values of often the
  /// color appears, usually from a source image.
  ///
  /// The list returned is of length <= [desired]. The recommended color is the
  /// first item, the least suitable is the last. There will always be at least
  /// one color returned. If all the input colors were not suitable for a theme,
  /// a default fallback color will be provided, ***user's default theme***. The default
  /// number of colors returned is 4, simply because thats the # of colors
  /// display in Android 12's wallpaper picker.
  static List<int> score(Map<int, int> colorsToPopulation,
      {int desired = 4, bool filter = true}) {
    var populationSum = 0.0;
    for (var population in colorsToPopulation.values) {
      populationSum += population;
    }

    // Turn the count of each color into a proportion by dividing by the total
    // count. Also, fill a cache of CAM16 colors representing each color, and
    // record the proportion of colors for each CAM16 hue.
    final argbToRawProportion = <int, double>{};
    final argbToHct = <int, Hct>{};
    final hueProportions = List<double>.filled(360, 0.0);
    for (var color in colorsToPopulation.keys) {
      final population = colorsToPopulation[color]!;
      final proportion = population / populationSum;
      argbToRawProportion[color] = proportion;

      final hct = Hct.fromInt(color);
      argbToHct[color] = hct;

      final hue = hct.hue.floor();
      hueProportions[hue] += proportion;
    }

    // Determine the proportion of the colors around each color, by summing the
    // proportions around each color's hue.
    final argbToHueProportion = <int, double>{};
    for (var entry in argbToHct.entries) {
      final color = entry.key;
      final cam = entry.value;
      final hue = cam.hue.round();

      var excitedProportion = 0.0;
      for (var i = hue - 15; i < hue + 15; i++) {
        final neighborHue = MathUtils.sanitizeDegreesInt(i);
        excitedProportion += hueProportions[neighborHue];
      }
      argbToHueProportion[color] = excitedProportion;
    }

    // Remove colors that are unsuitable, ex. very dark or unchromatic colors.
    // Also, remove colors that are very similar in hue.
    final filteredColors = filter
        ? _filter(argbToHueProportion, argbToHct)
        : argbToHueProportion.keys.toList();

    // Score the colors by their proportion, as well as how chromatic they are.
    final argbToScore = <int, double>{};
    for (var color in filteredColors) {
      final cam = argbToHct[color]!;
      final proportion = argbToHueProportion[color]!;

      final proportionScore = proportion * 100.0 * _weightProportion;

      final chromaWeight =
          cam.chroma < _targetChroma ? _weightChromaBelow : _weightChromaAbove;
      final chromaScore = (cam.chroma - _targetChroma) * chromaWeight;

      final score = proportionScore + chromaScore;
      argbToScore[color] = score;
    }

    final argbAndScoreSorted = argbToScore.entries
        .map((entry) => [entry.key, entry.value])
        .toList(growable: false);
    argbAndScoreSorted.sort((a, b) => a[1].compareTo(b[1]) * -1);
    final argbsScoreSorted =
        argbAndScoreSorted.map((e) => e[0]).toList(growable: false);
    final finalColorsToScore = <num, double>{};
    for (var differenceDegrees = 90.0;
        differenceDegrees >= 15.0;
        differenceDegrees--) {
      finalColorsToScore.clear();
      for (var color in argbsScoreSorted) {
        var duplicateHue = false;
        final cam = argbToHct[color]!;
        for (var alreadyChosenColor in finalColorsToScore.keys) {
          final alreadyChosenCam = argbToHct[alreadyChosenColor]!;
          if (MathUtils.differenceDegrees(cam.hue, alreadyChosenCam.hue) <
              differenceDegrees) {
            duplicateHue = true;
            break;
          }
        }
        if (!duplicateHue) {
          finalColorsToScore[color] = argbToScore[color]!;
        }
      }
      if (finalColorsToScore.length >= desired) {
        break;
      }
    }

    // Ensure the list of colors returned is sorted such that the first in the
    // list is the most suitable, and the last is the least suitable.
    final colorsByScoreDescending = finalColorsToScore.entries
        .map((entry) => _ArgbAndScore(entry.key.toInt(), entry.value))
        .toList();
    colorsByScoreDescending.sort();

    // Ensure that at least one color is returned.
    if (colorsByScoreDescending.isEmpty) {
      return [AppSettings.instance.defaultTheme]; // Default theme
    }
    return colorsByScoreDescending.map((e) => e.argb).toList();
  }

  /// Remove any colors that are completely inappropriate choices for a theme
  /// colors, colors that are virtually grayscale, or whose hue represents
  /// a very small portion of the image.
  static List<int> _filter(
      Map<int, double> colorsToExcitedProportion, Map<int, Hct> argbToHct) {
    final filtered = <int>[];
    for (var entry in argbToHct.entries) {
      final color = entry.key;
      final cam = entry.value;
      final proportion = colorsToExcitedProportion[color]!;

      if (cam.chroma >= _cutoffChroma &&
          proportion > _cutoffExcitedProportion) {
        filtered.add(color);
      }
    }
    return filtered;
  }

  static Map<int, double> argbToProportion(Map<int, int> argbToCount) {
    final totalPopulation =
        argbToCount.values.reduce((a, b) => a + b).floorToDouble();
    final argbToHct =
        argbToCount.map((key, value) => MapEntry(key, Hct.fromInt(key)));
    final hueProportions = List<double>.filled(360, 0.0);
    for (var argb in argbToHct.keys) {
      final cam = argbToHct[argb]!;
      final hue = cam.hue.floor();
      hueProportions[hue] += (argbToCount[argb]! / totalPopulation);
    }

    // Determine the proportion of the colors around each color, by summing the
    // proportions around each color's hue.
    final intToProportion = <int, double>{};
    for (var entry in argbToHct.entries) {
      final argb = entry.key;
      final cam = entry.value;
      final hue = cam.hue.round();

      var excitedProportion = 0.0;
      for (var i = hue - 15; i < hue + 15; i++) {
        final neighborHue = MathUtils.sanitizeDegreesInt(i);
        excitedProportion += hueProportions[neighborHue];
      }
      intToProportion[argb] = excitedProportion;
    }
    return intToProportion;
  }
}