import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/playlist.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

/// 由[playlist]和[audioIndex]确定audio，而不是直接传入audio，
/// 这是为了实现点击列表项播放乐曲时指定该列表为播放列表。
/// 同时，播放乐曲时也是需要index和playlist来定位audio和设置播放列表。
class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.audioIndex,
    required this.playlist,
    this.focus = false,
  });

  final int audioIndex;
  final List<Audio> playlist;
  final bool focus;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audio = playlist[audioIndex];

    final menuItemStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(
        theme.palette.surfaceContainer,
      ),
      surfaceTintColor: MaterialStatePropertyAll(
        theme.palette.surfaceContainer,
      ),
      foregroundColor: MaterialStatePropertyAll(
        theme.palette.onSurface,
      ),
      overlayColor: MaterialStatePropertyAll(
        theme.palette.onSurface.withOpacity(0.08),
      ),
    );

    final menuController = MenuController();

    return SizedBox(
      height: 64.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.0),
        onTap: () {
          try {
            PlayService.instance.play(audioIndex, playlist);
          } catch (e) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(e.toString())));
          }
        },
        onSecondaryTapDown: (details) {
          menuController.open(position: details.localPosition);
        },
        hoverColor: theme.palette.onSurface.withOpacity(0.08),
        highlightColor: theme.palette.onSurface.withOpacity(0.12),
        splashColor: theme.palette.onSurface.withOpacity(0.12),
        child: MenuAnchor(
          controller: menuController,
          style: MenuStyle(
            backgroundColor: MaterialStatePropertyAll(
              theme.palette.surfaceContainer,
            ),
            surfaceTintColor: MaterialStatePropertyAll(
              theme.palette.surfaceContainer,
            ),
          ),
          menuChildren: [
            /// artists
            SubmenuButton(
              menuStyle: MenuStyle(
                backgroundColor: MaterialStatePropertyAll(
                  theme.palette.surfaceContainer,
                ),
                surfaceTintColor: MaterialStatePropertyAll(
                  theme.palette.surfaceContainer,
                ),
              ),
              style: menuItemStyle,
              menuChildren: List.generate(
                audio.splitedArtists.length,
                (i) => MenuItemButton(
                  style: menuItemStyle,
                  onPressed: () {
                    final Artist artist = AudioLibrary
                        .instance.artistCollection[audio.splitedArtists[i]]!;
                    context.push(
                      app_paths.ARTIST_DETAIL_PAGE,
                      extra: artist,
                    );
                  },
                  leadingIcon: Icon(
                    Symbols.artist,
                    color: theme.palette.onSurface,
                  ),
                  child: Text(audio.splitedArtists[i]),
                ),
              ),
              child: const Text("艺术家"),
            ),

            /// album
            MenuItemButton(
              style: menuItemStyle,
              onPressed: () {
                final Album album =
                    AudioLibrary.instance.albumCollection[audio.album]!;
                context.push(app_paths.ALBUM_DETAIL_PAGE, extra: album);
              },
              leadingIcon: Icon(
                Symbols.album,
                color: theme.palette.onSurface,
              ),
              child: Text(audio.album),
            ),

            /// add to playlist
            SubmenuButton(
              menuStyle: MenuStyle(
                backgroundColor: MaterialStatePropertyAll(
                  theme.palette.surfaceContainer,
                ),
                surfaceTintColor: MaterialStatePropertyAll(
                  theme.palette.surfaceContainer,
                ),
              ),
              style: menuItemStyle,
              menuChildren: List.generate(
                PLAYLISTS.length,
                (i) => MenuItemButton(
                  onPressed: () {
                    final added = PLAYLISTS[i]
                        .audios
                        .any((element) => element.path == audio.path);
                    if (!added) {
                      PLAYLISTS[i].audios.add(audio);
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "成功将“${audio.title}”添加到歌单“${PLAYLISTS[i].name}”",
                          style: TextStyle(color: theme.palette.onSecondary),
                        ),
                        backgroundColor: theme.palette.secondary,
                      ));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "歌曲“${audio.title}”已存在",
                          style: TextStyle(color: theme.palette.onSecondary),
                        ),
                        backgroundColor: theme.palette.secondary,
                      ));
                    }
                  },
                  leadingIcon: Icon(
                    Symbols.queue_music,
                    color: theme.palette.onSurface,
                  ),
                  child: Text(PLAYLISTS[i].name),
                ),
              ),
              child: const Text("添加到歌单"),
            ),
          ],
          builder: (context, controller, _) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  /// cover
                  FutureBuilder(
                    future: audio.cover,
                    builder: (context, snapshot) {
                      final theme = Provider.of<ThemeProvider>(context);

                      if (snapshot.data == null) {
                        return Icon(
                          Symbols.broken_image,
                          size: 48.0,
                          color: theme.palette.onSurface,
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
                  const SizedBox(width: 16.0),

                  /// title, artist and album
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.title,
                          style: TextStyle(
                            color: focus
                                ? theme.palette.primary
                                : theme.palette.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          "${audio.artist} - ${audio.album}",
                          style: TextStyle(
                            color: focus
                                ? theme.palette.primary
                                : theme.palette.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
