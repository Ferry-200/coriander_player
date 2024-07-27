import 'package:coriander_player/lyric/krc.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/qrc.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';

class LyricSourceLabel extends StatelessWidget {
  const LyricSourceLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListenableBuilder(
          listenable: PlayService.instance.lyricService,
          builder: (context, _) {
            final lyricService = PlayService.instance.lyricService;
            final lyric = lyricService.currLyricFuture;

            return FutureBuilder(
              future: lyric,
              builder: (context, snapshot) {
                final lyricResult = snapshot.data;
                if (lyricResult == null) {
                  return const Center(
                    child: SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                late final String decription;
                bool isLocal = false;
                if (lyricResult is Lrc) {
                  decription = lyricResult.source.name;
                  isLocal = lyricResult.source == LrcSource.local;
                } else if (lyricResult is Krc) {
                  decription = "Kugou";
                } else if (lyricResult is Qrc) {
                  decription = "QQ";
                } else {
                  decription = "无";
                  isLocal = !isLocal;
                }
                return TextButton(
                  onPressed: isLocal
                      ? lyricService.useOnlineLyric
                      : lyricService.useLocalLyric,
                  child: Text(
                    decription,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
