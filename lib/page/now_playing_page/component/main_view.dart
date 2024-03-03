import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class NowPlayingMainView extends StatelessWidget {
  const NowPlayingMainView({super.key, required this.pageControlls});

  final Widget pageControlls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Expanded(child: NowPlayingCover()),
          const SizedBox(height: 16.0),
          const NowPlayingTitle(),
          const NowPlayingArtistAlbum(),
          const SizedBox(height: 16.0),
          const NowPlayingProgressIndicator(),
          const PositionAndLength(),
          const SizedBox(height: 16.0),
          const NowPlayingControls(),
          const SizedBox(height: 16.0),
          pageControlls,
        ],
      ),
    );
  }
}

class NowPlayingControls extends StatelessWidget {
  const NowPlayingControls({super.key});

  @override
  Widget build(BuildContext context) {
    final playService = Provider.of<PlayService>(context);
    final theme = Provider.of<ThemeProvider>(context);
    final secondaryBtnStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(
        theme.palette.secondary,
      ),
      foregroundColor: MaterialStatePropertyAll(theme.palette.onSecondary),
      fixedSize: const MaterialStatePropertyAll(Size(64, 64)),
      overlayColor: MaterialStatePropertyAll(
        theme.palette.onSecondary.withOpacity(0.08),
      ),
    );
    return SizedBox(
      height: 64.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 播放/暂停
          SizedBox(
            width: 156,
            child: Material(
              color: theme.palette.primary,
              borderRadius: BorderRadius.circular(32.0),
              child: StreamBuilder(
                stream: playService.playerStateStream,
                initialData: playService.playerState,
                builder: (context, snapshot) {
                  late void Function() onTap;
                  if (snapshot.data! == PlayerState.playing) {
                    onTap = playService.pause;
                  } else if (snapshot.data! == PlayerState.completed) {
                    onTap = playService.playAgain;
                  } else {
                    onTap = playService.start;
                  }

                  return InkWell(
                    hoverColor: theme.palette.onPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(32.0),
                    onTap: onTap,
                    child: Center(
                      child: Icon(
                        snapshot.data! == PlayerState.playing
                            ? Symbols.pause
                            : Symbols.play_arrow,
                        color: theme.palette.onPrimary,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 24.0),

          /// 上一曲
          IconButton(
            onPressed: playService.lastAudio,
            icon: const Icon(Symbols.skip_previous),
            style: secondaryBtnStyle,
          ),
          const SizedBox(width: 24.0),

          /// 下一曲
          IconButton(
            onPressed: playService.nextAudio,
            icon: const Icon(Symbols.skip_next),
            style: secondaryBtnStyle,
          ),
        ],
      ),
    );
  }
}

class PositionAndLength extends StatelessWidget {
  const PositionAndLength({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;
    final lengthMinute = PlayService.instance.length ~/ 60;
    final lengthSecond = (PlayService.instance.length % 60).toInt();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// position
        StreamBuilder(
          stream: playService.positionStream,
          builder: (context, snapshot) {
            final pos = snapshot.data ?? 0;
            final minute = pos ~/ 60;
            final second = (pos % 60).toInt();
            return Text(
              "$minute:$second",
              style: TextStyle(
                color: theme.palette.onSecondaryContainer,
              ),
            );
          },
        ),

        /// length
        Text(
          nowPlaying == null ? "N/A" : "$lengthMinute:$lengthSecond",
          style: TextStyle(
            color: theme.palette.onSecondaryContainer,
          ),
        ),
      ],
    );
  }
}

class NowPlayingProgressIndicator extends StatefulWidget {
  const NowPlayingProgressIndicator({super.key});

  @override
  State<NowPlayingProgressIndicator> createState() =>
      NowPlayingProgressIndicatorState();
}

class NowPlayingProgressIndicatorState
    extends State<NowPlayingProgressIndicator> {
  final dragProgress = ValueNotifier(0.0);
  bool isDragging = false;

  @override
  Widget build(BuildContext context) {
    final playService = Provider.of<PlayService>(context);
    final theme = Provider.of<ThemeProvider>(context);

    return GestureDetector(
      onHorizontalDragStart: (details) {
        isDragging = true;
        dragProgress.value = details.localPosition.dx / 400.0;
      },
      onHorizontalDragUpdate: (details) {
        dragProgress.value = details.localPosition.dx / 400.0;
      },
      onHorizontalDragEnd: (details) {
        isDragging = false;
        var progress = dragProgress.value;
        if (progress < 0) progress = 0;
        if (progress > 1) progress = 1;

        final position = progress * PlayService.instance.length;
        PlayService.instance.seek(position);
      },
      child: StreamBuilder(
        stream: playService.positionStream,
        builder: (context, snapshot) {
          final progress = (snapshot.data ?? 0) / playService.length;
          return ListenableBuilder(
            listenable: dragProgress,
            builder: (context, _) {
              return LinearProgressIndicator(
                value: isDragging ? dragProgress.value : progress,
                color: theme.palette.outline,
                backgroundColor: theme.palette.outlineVariant,
                minHeight: 12.0,
                borderRadius: BorderRadius.circular(6.0),
              );
            },
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    dragProgress.dispose();
  }
}

class NowPlayingArtistAlbum extends StatelessWidget {
  const NowPlayingArtistAlbum({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        nowPlaying == null
            ? "Enjoy Music"
            : "${nowPlaying.artist} - ${nowPlaying.album}",
        maxLines: 1,
        style: TextStyle(
          color: theme.palette.onSecondaryContainer,
        ),
      ),
    );
  }
}

class NowPlayingTitle extends StatelessWidget {
  const NowPlayingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        nowPlaying == null ? "Coriander Music" : nowPlaying.title,
        maxLines: 1,
        style: TextStyle(
          color: theme.palette.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}

class NowPlayingCover extends StatelessWidget {
  const NowPlayingCover({super.key});

  @override
  Widget build(BuildContext context) {
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;
    final theme = Provider.of<ThemeProvider>(context);

    return RepaintBoundary(
      child: nowPlaying == null
          ? FittedBox(
              child: Icon(
                Symbols.broken_image,
                size: 400.0,
                color: theme.palette.onSecondaryContainer,
              ),
            )
          : FutureBuilder(
              future: nowPlaying.bigCover,
              builder: (context, snapshot) {
                final theme = Provider.of<ThemeProvider>(context);
                if (snapshot.data == null) {
                  return FittedBox(
                    child: Icon(
                      Symbols.broken_image,
                      size: 400.0,
                      color: theme.palette.onSecondaryContainer,
                    ),
                  );
                }
                return Image(
                  image: snapshot.data!,
                  width: 400.0,
                  height: 400.0,
                );
              },
            ),
    );
  }
}
