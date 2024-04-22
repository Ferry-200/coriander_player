// ignore_for_file: camel_case_types

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/page/now_playing_page/component/current_playlist_view.dart';
import 'package:coriander_player/page/now_playing_page/component/lyric_source_view.dart';
import 'package:coriander_player/page/now_playing_page/component/main_view.dart';
import 'package:coriander_player/page/now_playing_page/component/title_bar.dart';
import 'package:coriander_player/page/now_playing_page/component/vertical_lyric_view.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage({super.key});

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  final lyricViewKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(80.0),
        child: NowPlayingPageTitleBar(),
      ),
      backgroundColor: theme.palette.secondaryContainer,
      body: ChangeNotifierProvider.value(
        value: PlayService.instance,
        builder: (context, _) {
          return ResponsiveBuilder2(builder: (context, screenType) {
            switch (screenType) {
              case ScreenType.small:
                return _NowPlayingBody_Small(lyricViewKey);
              case ScreenType.medium:
              case ScreenType.large:
                return _NowPlayingBody_Large(lyricViewKey);
            }
          });
        },
      ),
    );
  }
}

enum _ViewMode {
  onlyMain,
  withLyric,
  withPlaylist,
}

_ViewMode _viewMode = _ViewMode.onlyMain;

class _NowPlayingBody_Small extends StatefulWidget {
  const _NowPlayingBody_Small(this.lyricViewKey);

  final GlobalKey lyricViewKey;

  @override
  State<_NowPlayingBody_Small> createState() => __NowPlayingBody_SmallState();
}

class __NowPlayingBody_SmallState extends State<_NowPlayingBody_Small> {
  void openPlaylistView() {
    if (_viewMode == _ViewMode.withPlaylist) {
      setState(() {
        _viewMode = _ViewMode.onlyMain;
      });
    } else {
      setState(() {
        _viewMode = _ViewMode.withPlaylist;
      });
    }
  }

  void openLyricView() {
    if (_viewMode == _ViewMode.withLyric) {
      setState(() {
        _viewMode = _ViewMode.onlyMain;
      });
    } else {
      setState(() {
        _viewMode = _ViewMode.withLyric;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    late final List<Widget> mainWidgets;
    switch (_viewMode) {
      case _ViewMode.onlyMain:
        mainWidgets = const [
          Expanded(child: NowPlayingCover()),
          SizedBox(height: 16.0),
          NowPlayingTitle(),
          NowPlayingArtistAlbum(),
          SizedBox(height: 16.0),
          NowPlayingProgressIndicator(),
          PositionAndLength(),
        ];
        break;
      case _ViewMode.withLyric:
        mainWidgets = [
          Expanded(
            child: VerticalLyricView(key: widget.lyricViewKey),
          ),
          const SizedBox(height: 16.0),
          const _CompactAudioInfo(),
        ];
        break;
      case _ViewMode.withPlaylist:
        mainWidgets = const [
          Expanded(
            child: CurrentPlaylistView(),
          ),
          SizedBox(height: 16.0),
          _CompactAudioInfo(),
        ];
        break;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...mainWidgets,
              const SizedBox(height: 16.0),
              const NowPlayingControls(),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const _ToggleShuffle(),
                  const _TogglePlayMode(),
                  _LyricViewBtn(onTap: openLyricView),
                  _PlaylistViewBtn(onTap: openPlaylistView),
                  const _MoreActions(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompactAudioInfo extends StatelessWidget {
  const _CompactAudioInfo();

  @override
  Widget build(BuildContext context) {
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;
    final theme = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: nowPlaying == null
              ? Icon(
                  Symbols.broken_image,
                  size: 48.0,
                  color: theme.palette.onSecondaryContainer,
                )
              : FutureBuilder(
                  future: nowPlaying.cover,
                  builder: (context, snapshot) {
                    final theme = Provider.of<ThemeProvider>(context);
                    if (snapshot.data == null) {
                      return Icon(
                        Symbols.broken_image,
                        size: 48.0,
                        color: theme.palette.onSecondaryContainer,
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image(
                        image: snapshot.data!,
                        width: 48.0,
                        height: 48.0,
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(width: 8.0),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nowPlaying == null ? "Coriander Music" : nowPlaying.title,
                maxLines: 1,
                style: TextStyle(
                  color: theme.palette.onSecondaryContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 20.0,
                ),
              ),
              Text(
                nowPlaying == null
                    ? "Enjoy Music"
                    : "${nowPlaying.artist} - ${nowPlaying.album}",
                maxLines: 1,
                style: TextStyle(
                  color: theme.palette.onSecondaryContainer,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}

class _NowPlayingBody_Large extends StatefulWidget {
  const _NowPlayingBody_Large(this.lyricViewKey);

  final GlobalKey lyricViewKey;

  @override
  State<_NowPlayingBody_Large> createState() => __NowPlayingBody_LargeState();
}

class __NowPlayingBody_LargeState extends State<_NowPlayingBody_Large> {
  final playlistView = const Expanded(
    child: Align(
      alignment: Alignment.center,
      child: CurrentPlaylistView(),
    ),
  );

  late final lyricView = Expanded(
    child: Align(
      alignment: Alignment.center,
      child: VerticalLyricView(key: widget.lyricViewKey),
    ),
  );

  void openPlaylistView() {
    setState(() {
      _viewMode = _viewMode == _ViewMode.withPlaylist
          ? _ViewMode.onlyMain
          : _ViewMode.withPlaylist;
    });
  }

  void openLyricView() {
    setState(() {
      _viewMode = _viewMode == _ViewMode.withLyric
          ? _ViewMode.onlyMain
          : _ViewMode.withLyric;
    });
  }

  static const spacer = SizedBox(width: 48.0);

  @override
  Widget build(BuildContext context) {
    final mainView = Expanded(
      child: Align(
        alignment: Alignment.center,
        child: NowPlayingMainView(
          pageControlls: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const _ToggleShuffle(),
              const _TogglePlayMode(),
              _LyricViewBtn(onTap: openLyricView),
              _PlaylistViewBtn(onTap: openPlaylistView),
              const _MoreActions(),
            ],
          ),
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48.0, vertical: 16.0),
      child: Row(
        children: switch (_viewMode) {
          _ViewMode.onlyMain => [mainView],
          _ViewMode.withLyric => [mainView, spacer, lyricView],
          _ViewMode.withPlaylist => [mainView, spacer, playlistView],
        },
      ),
    );
  }
}

class _LyricViewBtn extends StatelessWidget {
  const _LyricViewBtn({required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return IconButton(
      onPressed: onTap,
      hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
      highlightColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
      splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
      icon: Icon(
        Symbols.lyrics,
        color: _viewMode == _ViewMode.withLyric
            ? theme.palette.onSecondaryContainer
            : theme.palette.onSecondaryContainer.withOpacity(0.5),
      ),
    );
  }
}

class _PlaylistViewBtn extends StatelessWidget {
  const _PlaylistViewBtn({required this.onTap});

  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return IconButton(
      onPressed: onTap,
      hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
      highlightColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
      splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
      icon: Icon(
        Symbols.queue_music,
        color: _viewMode == _ViewMode.withPlaylist
            ? theme.palette.onSecondaryContainer
            : theme.palette.onSecondaryContainer.withOpacity(0.5),
      ),
    );
  }
}

class _MoreActions extends StatelessWidget {
  const _MoreActions();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final playService = Provider.of<PlayService>(context);
    final nowPlaying = playService.nowPlaying;
    final menuItemStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(
        theme.palette.surface,
      ),
      foregroundColor: MaterialStatePropertyAll(
        theme.palette.onSurface,
      ),
      overlayColor: MaterialStatePropertyAll(
        theme.palette.onSecondaryContainer.withOpacity(0.08),
      ),
    );

    return nowPlaying == null
        ? Icon(
            Symbols.more_vert,
            color: theme.palette.onSecondaryContainer.withOpacity(0.5),
          )
        : MenuAnchor(
            style: MenuStyle(
              backgroundColor: MaterialStatePropertyAll(
                theme.palette.surface,
              ),
              surfaceTintColor: MaterialStatePropertyAll(
                theme.palette.surface,
              ),
            ),
            menuChildren: [
              SubmenuButton(
                menuStyle: MenuStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    theme.palette.surface,
                  ),
                  surfaceTintColor: MaterialStatePropertyAll(
                    theme.palette.surface,
                  ),
                ),
                style: menuItemStyle,
                menuChildren: List.generate(
                  nowPlaying.splitedArtists.length,
                  (i) => MenuItemButton(
                    style: menuItemStyle,
                    onPressed: () {
                      final Artist artist = AudioLibrary.instance
                          .artistCollection[nowPlaying.splitedArtists[i]]!;
                      context.pushReplacement(
                        app_paths.ARTIST_DETAIL_PAGE,
                        extra: artist,
                      );
                    },
                    leadingIcon: Icon(
                      Symbols.people,
                      color: theme.palette.onSurface,
                    ),
                    child: Text(nowPlaying.splitedArtists[i]),
                  ),
                ),
                child: const Text("艺术家"),
              ),
              MenuItemButton(
                style: menuItemStyle,
                onPressed: () {
                  final Album album =
                      AudioLibrary.instance.albumCollection[nowPlaying.album]!;
                  context.pushReplacement(app_paths.ALBUM_DETAIL_PAGE,
                      extra: album);
                },
                leadingIcon: Icon(
                  Symbols.album,
                  color: theme.palette.onSurface,
                ),
                child: Text(nowPlaying.album),
              ),
              MenuItemButton(
                style: menuItemStyle,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => LyricSourceView(audio: nowPlaying),
                  );
                },
                leadingIcon: Icon(
                  Symbols.lyrics,
                  color: theme.palette.onSurface,
                ),
                child: const Text("指定默认歌词"),
              ),
            ],
            builder: (context, controller, _) {
              return IconButton(
                onPressed: () {
                  if (controller.isOpen) {
                    controller.close();
                  } else {
                    controller.open();
                  }
                },
                hoverColor:
                    theme.palette.onSecondaryContainer.withOpacity(0.08),
                highlightColor:
                    theme.palette.onSecondaryContainer.withOpacity(0.12),
                splashColor:
                    theme.palette.onSecondaryContainer.withOpacity(0.12),
                icon: Icon(
                  Symbols.more_vert,
                  color: theme.palette.onSecondaryContainer,
                ),
              );
            },
          );
  }
}

class _TogglePlayMode extends StatelessWidget {
  const _TogglePlayMode();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return ListenableBuilder(
      listenable: PlayService.instance.playMode,
      builder: (context, _) {
        final playMode = PlayService.instance.playMode;
        late IconData result;
        if (playMode.value == PlayMode.forward) {
          result = Symbols.repeat;
        } else if (playMode.value == PlayMode.loop) {
          result = Symbols.repeat_on;
        } else {
          result = Symbols.repeat_one_on;
        }
        return IconButton(
          onPressed: () {
            if (playMode.value == PlayMode.forward) {
              playMode.value = PlayMode.loop;
            } else if (playMode.value == PlayMode.loop) {
              playMode.value = PlayMode.singleLoop;
            } else {
              playMode.value = PlayMode.forward;
            }
          },
          hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
          highlightColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          icon: Icon(
            result,
            color: theme.palette.onSecondaryContainer,
          ),
        );
      },
    );
  }
}

class _ToggleShuffle extends StatelessWidget {
  const _ToggleShuffle();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return ListenableBuilder(
      listenable: PlayService.instance.shuffle,
      builder: (context, _) {
        final playService = PlayService.instance;
        return IconButton(
          onPressed: () {
            playService.toggleShuffle();
          },
          hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
          highlightColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          icon: Icon(
            playService.shuffle.value ? Symbols.shuffle_on : Symbols.shuffle,
            color: theme.palette.onSecondaryContainer,
          ),
        );
      },
    );
  }
}
