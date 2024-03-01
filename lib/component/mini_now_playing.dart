import 'package:coriander_player/component/rectangle_progress_indicator.dart';
import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class MiniNowPlaying extends StatelessWidget {
  const MiniNowPlaying({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(builder: (context, screenType) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            8.0,
            0,
            8.0,
            screenType == ScreenType.small ? 8.0 : 32.0,
          ),
          child: SizedBox(
            height: 64.0,
            width: 600.0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: kElevationToShadow[4],
              ),
              child: LayoutBuilder(builder: (context, constraints) {
                return RectangleProgressIndicator(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  child: const _NowPlayingForeground(),
                );
              }),
            ),
          ),
        ),
      );
    });
  }
}

class _NowPlayingForeground extends StatelessWidget {
  const _NowPlayingForeground();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Material(
      type: MaterialType.transparency,
      borderRadius: BorderRadius.circular(12.0),
      child: InkWell(
        onTap: () => context.push(app_paths.NOW_PLAYING_PAGE),
        borderRadius: BorderRadius.circular(12.0),
        hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
        highlightColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
        splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListenableBuilder(
            listenable: PlayService.instance,
            builder: (context, _) {
              final theme = Provider.of<ThemeProvider>(context);
              final nowPlaying = PlayService.instance.nowPlaying;
              return Row(
                children: [
                  /// now playing cover
                  nowPlaying != null
                      ? FutureBuilder(
                          future: nowPlaying.cover,
                          builder: (context, snapshot) {
                            if (snapshot.data == null) {
                              return Icon(
                                Symbols.broken_image,
                                size: 48.0,
                                color: theme.palette.onSecondaryContainer,
                              );
                            }

                            return DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: kElevationToShadow[4],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image(
                                  image: snapshot.data!,
                                  width: 48.0,
                                  height: 48.0,
                                ),
                              ),
                            );
                          },
                        )
                      : Icon(
                          Symbols.music_note,
                          size: 48.0,
                          color: theme.palette.onSecondaryContainer,
                        ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /// title
                        Text(
                          nowPlaying != null
                              ? nowPlaying.title
                              : "Coriander Music",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.palette.onSecondaryContainer,
                          ),
                        ),

                        /// artist - album
                        Text(
                          nowPlaying != null
                              ? "${nowPlaying.artist} - ${nowPlaying.album}"
                              : "Enjoy your music.",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: theme.palette.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),

                  /// start or pause
                  StreamBuilder(
                    stream: PlayService.instance.playerStateStream,
                    initialData: PlayService.instance.playerState,
                    builder: (context, snapshot) {
                      late void Function() onPressed;
                      if (snapshot.data! == PlayerState.playing) {
                        onPressed = PlayService.instance.pause;
                      } else if (snapshot.data! == PlayerState.completed) {
                        onPressed = PlayService.instance.playAgain;
                      } else {
                        onPressed = PlayService.instance.start;
                      }

                      return IconButton(
                        onPressed: onPressed,
                        icon: Icon(
                          snapshot.data! == PlayerState.playing
                              ? Symbols.pause
                              : Symbols.play_arrow,
                        ),
                        style: theme.primaryIconButtonStyle,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
