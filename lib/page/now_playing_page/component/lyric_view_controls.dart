import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/page/now_playing_page/component/lyric_source_view.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

enum LyricTextAlign {
  left,
  center,
  right;

  static LyricTextAlign? fromString(String lyricTextAlign) {
    for (var value in LyricTextAlign.values) {
      if (value.name == lyricTextAlign) return value;
    }
    return null;
  }
}

class LyricViewController extends ChangeNotifier {
  final nowPlayingPagePref = AppPreference.instance.nowPlayingPagePref;
  late LyricTextAlign lyricTextAlign = nowPlayingPagePref.lyricTextAlign;
  late double lyricFontSize = nowPlayingPagePref.lyricFontSize;
  late double translationFontSize = nowPlayingPagePref.translationFontSize;

  /// 在左对齐、居中、右对齐之间循环切换
  void switchLyricTextAlign() {
    lyricTextAlign = switch (lyricTextAlign) {
      LyricTextAlign.left => LyricTextAlign.center,
      LyricTextAlign.center => LyricTextAlign.right,
      LyricTextAlign.right => LyricTextAlign.left,
    };

    nowPlayingPagePref.lyricTextAlign = lyricTextAlign;
    notifyListeners();
  }

  void increaseFontSize() {
    lyricFontSize += 1;
    translationFontSize += 1;

    nowPlayingPagePref.lyricFontSize = lyricFontSize;
    nowPlayingPagePref.translationFontSize = translationFontSize;
    notifyListeners();
  }

  void decreaseFontSize() {
    if (translationFontSize <= 14) return;

    lyricFontSize -= 1;
    translationFontSize -= 1;

    nowPlayingPagePref.lyricFontSize = lyricFontSize;
    nowPlayingPagePref.translationFontSize = translationFontSize;
    notifyListeners();
  }
}

class LyricViewControls extends StatelessWidget {
  const LyricViewControls({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SetLyricSourceBtn(),
          SizedBox(height: 8.0),
          _LyricAlignSwitchBtn(),
          SizedBox(height: 8.0),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IncreaseFontSizeBtn(),
              SizedBox(width: 8.0),
              _DecreaseFontSizeBtn(),
            ],
          )
        ],
      ),
    );
  }
}

class _LyricAlignSwitchBtn extends StatelessWidget {
  const _LyricAlignSwitchBtn();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    return IconButton(
      onPressed: lyricViewController.switchLyricTextAlign,
      tooltip: "切换歌词对齐方向",
      color: scheme.onSecondaryContainer,
      icon: Icon(switch (lyricViewController.lyricTextAlign) {
        LyricTextAlign.left => Symbols.format_align_left,
        LyricTextAlign.center => Symbols.format_align_center,
        LyricTextAlign.right => Symbols.format_align_right,
      }),
    );
  }
}

class _IncreaseFontSizeBtn extends StatelessWidget {
  const _IncreaseFontSizeBtn();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    return IconButton(
      onPressed: lyricViewController.increaseFontSize,
      tooltip: "增大歌词字体",
      color: scheme.onSecondaryContainer,
      icon: const Icon(Symbols.text_increase),
    );
  }
}

class _DecreaseFontSizeBtn extends StatelessWidget {
  const _DecreaseFontSizeBtn();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    return IconButton(
      onPressed: lyricViewController.decreaseFontSize,
      tooltip: "减小歌词字体",
      color: scheme.onSecondaryContainer,
      icon: const Icon(Symbols.text_decrease),
    );
  }
}
