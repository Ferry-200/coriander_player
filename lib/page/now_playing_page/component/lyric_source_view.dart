import 'dart:math';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/music_matcher.dart';
import 'package:coriander_player/page/now_playing_page/component/vertical_lyric_view.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:coriander_player/lyric/lyric_converter.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart' as rust;

class SetLyricSourceBtn extends StatelessWidget {
  const SetLyricSourceBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlayService.instance.lyricService,
      builder: (context, _) => FutureBuilder(
        future: PlayService.instance.lyricService.currLyricFuture,
        builder: (context, snapshot) {
          const loadingWidget = IconButton(
            onPressed: null,
            icon: SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(),
            ),
          );
          final lyricNullable = snapshot.data;
          final isLocal = lyricNullable == null
              ? null
              : (lyricNullable is Lrc &&
                  lyricNullable.source == LrcSource.local);
          return switch (snapshot.connectionState) {
            ConnectionState.none => loadingWidget,
            ConnectionState.waiting => loadingWidget,
            ConnectionState.active => loadingWidget,
            ConnectionState.done => _SetLyricSourceBtn(isLocal: isLocal),
          };
        },
      ),
    );
  }
}

class _SetLyricSourceBtn extends StatelessWidget {
  final bool? isLocal;
  const _SetLyricSourceBtn({this.isLocal});

  /// 保存当前歌词到音频文件
  Future<void> _saveLyricToFile(BuildContext context) async {
    final playbackService = PlayService.instance.playbackService;
    final lyricService = PlayService.instance.lyricService;

    // 检查是否有正在播放的音频
    final nowPlaying = playbackService.nowPlaying;
    if (nowPlaying == null) {
      _showSnackBar(context, '没有正在播放的音频', isError: true);
      return;
    }

    // 检查文件是否支持歌词写入
    try {
      final canWrite = await rust.canWriteLyricsToFile(path: nowPlaying.path);
      if (!canWrite) {
        _showSnackBar(context, '当前音频文件不支持歌词写入（仅支持MP3格式）', isError: true);
        return;
      }
    } catch (e) {
      _showSnackBar(context, '检查文件支持时出错: $e', isError: true);
      return;
    }

    // 获取当前歌词
    final lyric = await lyricService.currLyricFuture;
    if (lyric == null) {
      _showSnackBar(context, '没有可用的歌词', isError: true);
      return;
    }

    // 转换歌词数据为LRC格式
    final lrcText = LyricConverter.generateLrcText(lyric);

    // 调用Rust API写入歌词（只写入USLT帧）
    try {
      await rust.writeLyricsToFile(
        path: nowPlaying.path,
        lrcText: lrcText,
        language: 'zho', // 中文
        description: 'Coriander Player',
      );
      _showSnackBar(context, '歌词保存成功');
    } catch (e) {
      _showSnackBar(context, '歌词保存失败: $e', isError: true);
    }
  }

  /// 显示操作结果提示
  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final scheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? scheme.error : scheme.primary,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lyricService = PlayService.instance.lyricService;
    return MenuAnchor(
      onOpen: () {
        ALWAYS_SHOW_LYRIC_VIEW_CONTROLS = true;
      },
      onClose: () {
        ALWAYS_SHOW_LYRIC_VIEW_CONTROLS = false;
      },
      menuChildren: [
        MenuItemButton(
          onPressed: () {
            final nowPlaying = PlayService.instance.playbackService.nowPlaying;
            showDialog<String>(
              context: context,
              builder: (context) => _SetLyricSourceDialog(audio: nowPlaying!),
            );
          },
          child: const Text("指定默认歌词"),
        ),
        MenuItemButton(
          onPressed: lyricService.useOnlineLyric,
          leadingIcon: isLocal == false ? const Icon(Symbols.check) : null,
          child: const Text("在线"),
        ),
        MenuItemButton(
          onPressed: lyricService.useLocalLyric,
          leadingIcon: isLocal == true ? const Icon(Symbols.check) : null,
          child: const Text("本地"),
        ),
        const Divider(),
        MenuItemButton(
          onPressed: () => _saveLyricToFile(context),
          child: const Text("保存歌词"),
        ),
      ],
      builder: (context, controller, _) => IconButton(
        onPressed: PlayService.instance.playbackService.nowPlaying == null
            ? null
            : () {
                if (controller.isOpen) {
                  controller.close();
                } else {
                  controller.open();
                }
              },
        icon: const Icon(Symbols.lyrics),
        color: scheme.onSecondaryContainer,
      ),
    );
  }
}

class _SetLyricSourceDialog extends StatelessWidget {
  const _SetLyricSourceDialog({required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 384, maxWidth: 600),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                title: const Text("使用本地歌词"),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                onTap: () {
                  LYRIC_SOURCES[audio.path] =
                      LyricSource(LyricSourceType.local);
                  PlayService.instance.lyricService.useLocalLyric();
                  Navigator.pop(context);
                },
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder(
                  future: uniSearch(audio),
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return const Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, i) => _LyricSourceTile(
                        audio: audio,
                        searchResult: snapshot.data![i],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LyricSourceTile extends StatefulWidget {
  const _LyricSourceTile({
    required this.searchResult,
    required this.audio,
  });

  final Audio audio;
  final SongSearchResult searchResult;

  @override
  State<_LyricSourceTile> createState() => _LyricSourceTileState();
}

class _LyricSourceTileState extends State<_LyricSourceTile> {
  late final lyric = getOnlineLyric(
    qqSongId: widget.searchResult.qqSongId,
    kugouSongHash: widget.searchResult.kugouSongHash,
    neteaseSongId: widget.searchResult.neteaseSongId,
  );
  @override
  Widget build(BuildContext context) {
    const loadingWidget = Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(),
        ),
      ),
    );
    return FutureBuilder(
      future: lyric,
      builder: (context, lyricSnapshot) =>
          switch (lyricSnapshot.connectionState) {
        ConnectionState.none => loadingWidget,
        ConnectionState.waiting => loadingWidget,
        ConnectionState.active => loadingWidget,
        ConnectionState.done =>
          lyricSnapshot.data == null || lyricSnapshot.data!.lines.isEmpty
              ? const SizedBox.shrink()
              : buildTile(
                  context,
                  widget.audio,
                  widget.searchResult,
                  lyricSnapshot.data!,
                ),
      },
    );
  }

  Widget buildTile(
    BuildContext context,
    Audio audio,
    SongSearchResult searchResult,
    Lyric lyric,
  ) {
    return ListTile(
      onTap: () {
        LyricSourceType source = switch (searchResult.source) {
          ResultSource.qq => LyricSourceType.qq,
          ResultSource.kugou => LyricSourceType.kugou,
          ResultSource.netease => LyricSourceType.netease,
        };
        LYRIC_SOURCES[audio.path] = LyricSource(
          source,
          qqSongId: searchResult.qqSongId,
          kugouSongHash: searchResult.kugouSongHash,
          neteaseSongId: searchResult.neteaseSongId,
        );
        PlayService.instance.lyricService.useSpecificLyric(lyric);

        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      leading: Text(lyric is Lrc ? "LRC" : "逐字"),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            searchResult.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            "${searchResult.artists} - ${searchResult.album}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      subtitle: StreamBuilder(
        stream: PlayService.instance.playbackService.positionStream,
        builder: (context, positionSnapshot) {
          final currLineIndex = max(lyric.lines.lastIndexWhere(
            (element) {
              return element.start.inMilliseconds <
                  (positionSnapshot.data ?? 0) * 1000;
            },
          ), 0);

          final LyricLine currLine = lyric.lines[currLineIndex];
          if (currLine is LrcLine) {
            return Text(
              "当前：${currLine.content}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          } else {
            final syncLine = currLine as SyncLyricLine;

            return Text(
              "当前：${syncLine.content}${syncLine.translation != null ? "┃${syncLine.translation}" : ""}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }
        },
      ),
    );
  }
}
