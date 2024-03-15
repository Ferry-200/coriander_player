import 'package:coriander_player/lyric/krc.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/qrc.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LyricSourceLabel extends StatelessWidget {
  const LyricSourceLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          height: 24.0,
          width: 48.0,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: theme.palette.outline),
            ),
            child: Center(
              child: ValueListenableBuilder(
                valueListenable: PlayService.instance.currentLyric,
                builder: (context, lyric, _) {
                  late final String decription;
                  if (lyric is Lrc) {
                    decription = lyric.source.name;
                  } else if (lyric is Krc) {
                    decription = "Kugou";
                  } else if (lyric is Qrc) {
                    decription = "QQ";
                  } else {
                    decription = "无";
                  }
                  return Text(
                    decription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.palette.onSecondaryContainer,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
