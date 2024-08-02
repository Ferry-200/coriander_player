import 'package:desktop_lyric/component/action_row.dart';
import 'package:desktop_lyric/component/lyric_line_view.dart';
import 'package:desktop_lyric/component/now_playing_info.dart';
import 'package:desktop_lyric/player_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

final LYRIC_TEXT_KEY = GlobalKey();
final TRANSLATION_TEXT_KEY = GlobalKey();

final TEXT_DISPLAY_CONTROLLER = TextDisplayController();

bool ALWAYS_SHOW_ACTION_ROW = false;

/// 在保证正确布局的前提下缩小窗口大小
void resizeWithForegroundSize() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    double? lyricTextHeight;
    double? translationTextHeight;

    final lyricTextRenderObject =
        LYRIC_TEXT_KEY.currentContext?.findRenderObject();
    if (lyricTextRenderObject != null) {
      final renderBox = lyricTextRenderObject as RenderBox;
      lyricTextHeight = renderBox.size.height;
    }

    final translationTextRenderObject =
        TRANSLATION_TEXT_KEY.currentContext?.findRenderObject();
    if (translationTextRenderObject != null) {
      final renderBox = translationTextRenderObject as RenderBox;
      translationTextHeight = renderBox.size.height;
    }

    if (lyricTextHeight != null) {
      final windowHeight = 8 // vertical padding
          + 40 // ActionRow/NowPlayinginfo
          + 8 // spacer between (ActionRow/NowPlayingInfo) and LyricLineView
          + lyricTextHeight
          + (translationTextHeight ?? 0)
          + 8; // vertical padding
      // 保证不会溢出
      windowManager.setSize(Size(800, windowHeight + 1));
    }
  });
}

class TextDisplayController extends ChangeNotifier {
  double lyricFontSize = 22.0;
  double translationFontSize = 18.0;

  /// true: 使用指定的颜色
  /// false: 跟随播放器主题（默认）
  bool hasSpecifiedColor = false;
  Color specifiedColor = PlayerStates.instance.themeChanged.value.primary;

  /// 每次增加 1
  void increaseLyricFontSize() {
    lyricFontSize += 1;
    translationFontSize += 1;
    notifyListeners();

    resizeWithForegroundSize();
  }

  /// 每次减少 1，最小 18
  void decreaseLyricFontSize() {
    if (translationFontSize <= 14) return;

    lyricFontSize -= 1;
    translationFontSize -= 1;
    notifyListeners();

    resizeWithForegroundSize();
  }

  /// 指定字体颜色
  void spcifiyColor(Color color) {
    specifiedColor = color;
    hasSpecifiedColor = true;
    notifyListeners();
  }

  /// 让歌词颜色跟随播放器主题
  void usePlayerTheme() {
    hasSpecifiedColor = false;
    notifyListeners();
  }
}

class DesktopLyricForeground extends StatelessWidget {
  final bool isHovering;
  const DesktopLyricForeground({super.key, required this.isHovering});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ChangeNotifierProvider.value(
        value: TEXT_DISPLAY_CONTROLLER,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 150),
              child: isHovering || ALWAYS_SHOW_ACTION_ROW
                  ? const RepaintBoundary(child: ActionRow())
                  : const RepaintBoundary(child: NowPlayingInfo()),
            ),
            const SizedBox(height: 8),
            const Expanded(child: LyricLineView()),
          ],
        ),
      ),
    );
  }
}
