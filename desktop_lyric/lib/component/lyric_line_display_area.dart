import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/player_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LyricLineDisplayArea extends StatelessWidget {
  const LyricLineDisplayArea({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: PlayerStates.instance.lyricLine,
      builder: (context, lyricLine, _) {
        final theme = context.watch<ThemeChangedMessage>();

        final contentText = Text(
          lyricLine.content,
          style: TextStyle(
            color: theme.primary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
        );

        if (lyricLine.translation == null) {
          return contentText;
        }

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            contentText,
            Text(
              lyricLine.translation!,
              style: TextStyle(
                color: theme.primary,
                fontSize: 18,
              ),
              maxLines: 1,
            ),
          ],
        );
      },
    );
  }
}
