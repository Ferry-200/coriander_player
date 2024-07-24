import 'package:coriander_player/extensions.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

/// 由[playlist]和[audioIndex]确定audio，而不是直接传入audio，
/// 这是为了实现点击列表项播放乐曲时指定该列表为播放列表。
/// 同时，播放乐曲时也是需要index和playlist来定位audio和设置播放列表。
class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.audioIndex,
    required this.playlist,
    this.focus = false,
    this.action,
    this.multiSelectController,
  });

  final int audioIndex;
  final List<Audio> playlist;
  final bool focus;
  final Widget? action;
  final MultiSelectController? multiSelectController;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final audio = playlist[audioIndex];
    final menuController = MenuController();

    return Ink(
      height: 64.0,
      decoration: BoxDecoration(
        color: multiSelectController == null
            ? Colors.transparent
            : multiSelectController!.selected.contains(audio)
                ? scheme.secondaryContainer
                : Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          if (multiSelectController == null) {
            try {
              PlayService.instance.play(audioIndex, playlist);
            } catch (e) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(e.toString())));
            }
          } else {
            if (multiSelectController!.selected.contains(audio)) {
              multiSelectController!.unselect(audio);
            } else {
              multiSelectController!.select(audio);
            }
          }
        },
        onSecondaryTapDown: (details) {
          if (multiSelectController?.enableMultiSelectView == true) return;

          menuController.open(position: details.localPosition);
        },
        child: MenuAnchor(
          controller: menuController,
          menuChildren: [
            /// artists
            SubmenuButton(
              menuChildren: List.generate(
                audio.splitedArtists.length,
                (i) => MenuItemButton(
                  onPressed: () {
                    final Artist artist = AudioLibrary
                        .instance.artistCollection[audio.splitedArtists[i]]!;
                    context.push(
                      app_paths.ARTIST_DETAIL_PAGE,
                      extra: artist,
                    );
                  },
                  leadingIcon: const Icon(Symbols.artist),
                  child: Text(audio.splitedArtists[i]),
                ),
              ),
              child: const Text("艺术家"),
            ),

            /// album
            MenuItemButton(
              onPressed: () {
                final Album album =
                    AudioLibrary.instance.albumCollection[audio.album]!;
                context.push(app_paths.ALBUM_DETAIL_PAGE, extra: album);
              },
              leadingIcon: const Icon(Symbols.album),
              child: Text(audio.album),
            ),

            /// 下一首播放
            MenuItemButton(
              onPressed: () {
                PlayService.instance.addToNext(audio);
              },
              leadingIcon: const Icon(Symbols.plus_one),
              child: const Text("下一首播放"),
            ),

            /// 多选
            MenuItemButton(
              onPressed: () {
                multiSelectController?.useMultiSelectView(true);
                multiSelectController?.select(audio);
              },
              leadingIcon: const Icon(Symbols.select),
              child: const Text("多选"),
            ),

            /// add to playlist
            SubmenuButton(
              menuChildren: List.generate(
                PLAYLISTS.length,
                (i) => MenuItemButton(
                  onPressed: () {
                    final added = PLAYLISTS[i]
                        .audios
                        .any((element) => element.path == audio.path);
                    if (added) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text("歌曲“${audio.title}”已存在"),
                      ));
                      return;
                    }

                    PLAYLISTS[i].audios.add(audio);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "成功将“${audio.title}”添加到歌单“${PLAYLISTS[i].name}”",
                      ),
                    ));
                  },
                  leadingIcon: const Icon(Symbols.queue_music),
                  child: Text(PLAYLISTS[i].name),
                ),
              ),
              child: const Text("添加到歌单"),
            ),

            /// to detail page
            MenuItemButton(
              onPressed: () {
                context.push(app_paths.AUDIO_DETAIL_PAGE, extra: audio);
              },
              leadingIcon: const Icon(Symbols.info),
              child: const Text("详细信息"),
            ),
          ],
          builder: (context, controller, _) {
            final textColor = focus ? scheme.primary : scheme.onSurface;
            final placeholder = Icon(
              Symbols.broken_image,
              size: 48.0,
              color: scheme.onSurface,
            );

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  /// cover
                  FutureBuilder(
                    future: audio.cover,
                    builder: (context, snapshot) {
                      if (snapshot.data == null) {
                        return placeholder;
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image(
                          image: snapshot.data!,
                          width: 48.0,
                          height: 48.0,
                          errorBuilder: (_, __, ___) => placeholder,
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
                          style: TextStyle(color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(width: 4.0),
                        Text(
                          "${audio.artist} - ${audio.album}",
                          style: TextStyle(color: textColor),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Text(
                    Duration(seconds: audio.duration).toStringHMMSS(),
                    style: TextStyle(
                      color: focus ? scheme.primary : scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  action ?? const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
