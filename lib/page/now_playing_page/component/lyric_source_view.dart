import 'dart:math';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/music_api/search_helper.dart';
import 'package:coriander_player/play_service.dart';
import 'package:flutter/material.dart';

class LyricSourceView extends StatefulWidget {
  const LyricSourceView({super.key, required this.audio});

  final Audio audio;

  @override
  State<LyricSourceView> createState() => _LyricSourceViewState();
}

class _LyricSourceViewState extends State<LyricSourceView> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                "默认歌词",
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 18.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ListTile(
              title: const Text("本地歌词"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onTap: () {
                LYRIC_SOURCES[widget.audio.path] =
                    LyricSource(LyricSourceType.local);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder(
                future: uniSearch(widget.audio),
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const Center(child: LinearProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, i) {
                      final item = snapshot.data![i];
                      return LyricSourceTile(
                        source: snapshot.data![i],
                        onTap: () {
                          late LyricSourceType source;
                          switch (item.source) {
                            case ResultSource.qq:
                              source = LyricSourceType.qq;
                              break;
                            case ResultSource.kugou:
                              source = LyricSourceType.kugou;
                              break;
                            case ResultSource.netease:
                              source = LyricSourceType.netease;
                              break;
                          }
                          LYRIC_SOURCES[widget.audio.path] = LyricSource(
                            source,
                            qqSongId: item.qqSongId,
                            kugouSongHash: item.kugouSongHash,
                            neteaseSongId: item.neteaseSongId,
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LyricSourceTile extends StatelessWidget {
  const LyricSourceTile({
    super.key,
    required this.source,
    required this.onTap,
  });

  final SongSearchResult source;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(source.source.name),
          Text(source.title),
          Text("${source.artists} - ${source.album}"),
        ],
      ),
      subtitle: FutureBuilder(
        future: getOnlineLyric(
          qqSongId: source.qqSongId,
          kugouSongHash: source.kugouSongHash,
          neteaseSongId: source.neteaseSongId,
        ),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return const LinearProgressIndicator();
            case ConnectionState.active:
            case ConnectionState.done:
              {
                final lyric = snapshot.data;
                if (lyric == null || lyric.lines.isEmpty) {
                  return const Text("无歌词");
                }
                return StreamBuilder(
                  stream: PlayService.instance.positionStream,
                  builder: (context, snapshot) {
                    final currLineIndex = max(lyric.lines.lastIndexWhere(
                      (element) {
                        return element.start.inMilliseconds <
                            (snapshot.data ?? 0) * 1000;
                      },
                    ), 0);
                    late final String content;
                    final LyricLine currLine = lyric.lines[currLineIndex];
                    if (currLine is UnsyncLyricLine) {
                      content = currLine.content;
                    } else {
                      content = (currLine as SyncLyricLine).content;
                    }
                    return Text("当前：$content");
                  },
                );
              }
          }
        },
      ),
    );
  }
}
