import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/player_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NowPlayingInfo extends StatelessWidget {
  const NowPlayingInfo({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();

    final textStyle = TextStyle(color: theme.primary);

    return ValueListenableBuilder(
      valueListenable: PlayerStates.instance.nowPlaying,
      builder: (context, nowPlaying, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(nowPlaying.title, style: textStyle),
            Text(
              "${nowPlaying.artist} - ${nowPlaying.album}",
              style: textStyle,
            ),
          ],
        );
      },
    );
  }
}
