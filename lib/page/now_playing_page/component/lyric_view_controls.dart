import 'package:coriander_player/page/now_playing_page/component/lyric_source_view.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

enum LyricTextAlign { left, center, right }

class LyricViewController extends ChangeNotifier {
  LyricTextAlign lyricTextAlign = LyricTextAlign.left;
  double lyricFontSize = 22.0;
  double translationFontSize = 18.0;

  /// 在左对齐、居中、右对齐之间循环切换
  void switchLyricTextAlign() {
    lyricTextAlign = switch (lyricTextAlign) {
      LyricTextAlign.left => LyricTextAlign.center,
      LyricTextAlign.center => LyricTextAlign.right,
      LyricTextAlign.right => LyricTextAlign.left,
    };
    notifyListeners();
  }

  void increaseFontSize() {
    lyricFontSize += 1;
    translationFontSize += 1;
    notifyListeners();
  }

  void decreaseFontSize() {
    if (translationFontSize <= 14) return;

    lyricFontSize -= 1;
    translationFontSize -= 1;
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
  const _LyricAlignSwitchBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    return IconButton(
      onPressed: lyricViewController.switchLyricTextAlign,
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
  const _IncreaseFontSizeBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    return IconButton(
      onPressed: lyricViewController.increaseFontSize,
      color: scheme.onSecondaryContainer,
      icon: const Icon(Symbols.text_increase),
    );
  }
}

class _DecreaseFontSizeBtn extends StatelessWidget {
  const _DecreaseFontSizeBtn({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricViewController = context.watch<LyricViewController>();

    return IconButton(
      onPressed: lyricViewController.decreaseFontSize,
      color: scheme.onSecondaryContainer,
      icon: const Icon(Symbols.text_decrease),
    );
  }
}
