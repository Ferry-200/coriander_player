import 'package:coriander_player/extensions.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
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

class FilledSecondaryIconButtonStyle extends ButtonStyle {
  FilledSecondaryIconButtonStyle(this.context)
      : super(
          animationDuration: kThemeChangeDuration,
          enableFeedback: true,
          alignment: Alignment.center,
        );

  final BuildContext context;
  late final ColorScheme scheme = Theme.of(context).colorScheme;

  // No default text style

  @override
  WidgetStateProperty<Color?>? get backgroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withOpacity(0.12);
        }
        if (states.contains(WidgetState.selected)) {
          return scheme.secondary;
        }
        return scheme.secondary;
      });

  @override
  WidgetStateProperty<Color?>? get foregroundColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return scheme.onSurface.withOpacity(0.38);
        }
        if (states.contains(WidgetState.selected)) {
          return scheme.onSecondary;
        }
        return scheme.onSecondary;
      });

  @override
  WidgetStateProperty<Color?>? get overlayColor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          if (states.contains(WidgetState.pressed)) {
            return scheme.onSecondary.withOpacity(0.1);
          }
          if (states.contains(WidgetState.hovered)) {
            return scheme.onSecondary.withOpacity(0.08);
          }
          if (states.contains(WidgetState.focused)) {
            return scheme.onSecondary.withOpacity(0.1);
          }
        }
        if (states.contains(WidgetState.pressed)) {
          return scheme.onSecondary.withOpacity(0.1);
        }
        if (states.contains(WidgetState.hovered)) {
          return scheme.onSecondary.withOpacity(0.08);
        }
        if (states.contains(WidgetState.focused)) {
          return scheme.onSecondary.withOpacity(0.1);
        }
        return Colors.transparent;
      });

  @override
  WidgetStateProperty<double>? get elevation =>
      const WidgetStatePropertyAll<double>(0.0);

  @override
  WidgetStateProperty<Color>? get shadowColor =>
      const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<Color>? get surfaceTintColor =>
      const WidgetStatePropertyAll<Color>(Colors.transparent);

  @override
  WidgetStateProperty<EdgeInsetsGeometry>? get padding =>
      const WidgetStatePropertyAll<EdgeInsetsGeometry>(EdgeInsets.all(8.0));

  @override
  WidgetStateProperty<Size>? get minimumSize =>
      const WidgetStatePropertyAll<Size>(Size(64.0, 64.0));

  // No default fixedSize

  @override
  WidgetStateProperty<Size>? get maximumSize =>
      const WidgetStatePropertyAll<Size>(Size.infinite);

  @override
  WidgetStateProperty<double>? get iconSize =>
      const WidgetStatePropertyAll<double>(24.0);

  @override
  WidgetStateProperty<BorderSide?>? get side => null;

  @override
  WidgetStateProperty<OutlinedBorder>? get shape =>
      const WidgetStatePropertyAll<OutlinedBorder>(StadiumBorder());

  @override
  WidgetStateProperty<MouseCursor?>? get mouseCursor =>
      WidgetStateProperty.resolveWith((Set<WidgetState> states) {
        if (states.contains(WidgetState.disabled)) {
          return SystemMouseCursors.basic;
        }
        return SystemMouseCursors.click;
      });

  @override
  VisualDensity? get visualDensity => VisualDensity.standard;

  @override
  MaterialTapTargetSize? get tapTargetSize =>
      Theme.of(context).materialTapTargetSize;

  @override
  InteractiveInkFeatureFactory? get splashFactory =>
      Theme.of(context).splashFactory;
}

class NowPlayingControls extends StatelessWidget {
  const NowPlayingControls({super.key});

  @override
  Widget build(BuildContext context) {
    final playService = Provider.of<PlayService>(context);
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 64.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          /// 播放/暂停
          SizedBox(
            width: 156,
            child: Material(
              color: scheme.primary,
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
                    borderRadius: BorderRadius.circular(32.0),
                    onTap: onTap,
                    child: Center(
                      child: Icon(
                        snapshot.data! == PlayerState.playing
                            ? Symbols.pause
                            : Symbols.play_arrow,
                        color: scheme.onPrimary,
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
            style: FilledSecondaryIconButtonStyle(context),
          ),
          const SizedBox(width: 24.0),

          /// 下一曲
          IconButton(
            onPressed: playService.nextAudio,
            icon: const Icon(Symbols.skip_next),
            style: FilledSecondaryIconButtonStyle(context),
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
    final scheme = Theme.of(context).colorScheme;
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;
    final length = PlayService.instance.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        /// position
        StreamBuilder(
          stream: playService.positionStream,
          builder: (context, snapshot) {
            final pos = snapshot.data ?? 0;
            return Text(
              Duration(milliseconds: (pos * 1000).round()).toStringHMMSS(),
              style: TextStyle(color: scheme.onSecondaryContainer),
            );
          },
        ),

        /// length
        Text(
          nowPlaying == null
              ? "N/A"
              : Duration(milliseconds: (length * 1000).round()).toStringHMMSS(),
          style: TextStyle(color: scheme.onSecondaryContainer),
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
    final scheme = Theme.of(context).colorScheme;
    final playService = Provider.of<PlayService>(context);

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
                minHeight: 12.0,
                borderRadius: BorderRadius.circular(6.0),
                color: scheme.outline,
                backgroundColor: scheme.outlineVariant,
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
    final scheme = Theme.of(context).colorScheme;
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        nowPlaying == null
            ? "Enjoy Music"
            : "${nowPlaying.artist} - ${nowPlaying.album}",
        maxLines: 1,
        style: TextStyle(color: scheme.onSecondaryContainer),
      ),
    );
  }
}

class NowPlayingTitle extends StatelessWidget {
  const NowPlayingTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;

    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        nowPlaying == null ? "Coriander Music" : nowPlaying.title,
        maxLines: 1,
        style: TextStyle(
          color: scheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 20,
        ),
      ),
    );
  }
}

class NowPlayingCover extends StatefulWidget {
  const NowPlayingCover({super.key});

  @override
  State<NowPlayingCover> createState() => _NowPlayingCoverState();
}

class _NowPlayingCoverState extends State<NowPlayingCover> {
  final playService = PlayService.instance;
  Future<ImageProvider<Object>?>? nowPlayingCover;

  void updateCover() {
    setState(() {
      nowPlayingCover = playService.nowPlaying?.largeCover;
    });
  }

  @override
  void initState() {
    super.initState();
    playService.addListener(updateCover);
    nowPlayingCover = playService.nowPlaying?.largeCover;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final placeholder = FittedBox(
      child: Icon(
        Symbols.broken_image,
        size: 400.0,
        color: scheme.onSecondaryContainer,
      ),
    );

    return RepaintBoundary(
      child: nowPlayingCover == null
          ? placeholder
          : FutureBuilder(
              future: nowPlayingCover,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return placeholder;
                }
                return Image(
                  image: snapshot.data!,
                  width: 400.0,
                  height: 400.0,
                  errorBuilder: (_, __, ___) => placeholder,
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    playService.removeListener(updateCover);
    super.dispose();
  }
}
