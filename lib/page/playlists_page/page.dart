import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  void newPlaylist(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    showDialog<String>(
      context: context,
      builder: (context) => _NewPlaylistDialog(theme: theme),
    ).then((value) {
      if (value != null) {
        setState(() {
          PLAYLISTS.add(Playlist(value, []));
        });
      }
    });
  }

  void editPlaylist(
    BuildContext context,
    Playlist playlist,
  ) {
    final theme = Provider.of<ThemeProvider>(context, listen: false);
    showDialog<String>(
      context: context,
      builder: (context) => _EditPlaylistDialog(theme: theme),
    ).then((value) {
      if (value != null) {
        setState(() {
          playlist.name = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return PageScaffold(
      title: "歌单",
      actions: [
        FilledButton.icon(
          onPressed: () => newPlaylist(context),
          icon: const Icon(Symbols.add),
          label: const Text("新建歌单"),
          style: theme.primaryButtonStyle,
        ),
      ],
      body: Material(
        type: MaterialType.transparency,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 96.0),
          itemCount: PLAYLISTS.length,
          itemBuilder: (context, i) => ListTile(
            title: Text(PLAYLISTS[i].name),
            subtitle: Text("${PLAYLISTS[i].audios.length}首乐曲"),
            trailing: Wrap(
              spacing: 8.0,
              children: [
                editPlaylistBtn(context, i, theme),
                removePlaylistBtn(i, theme),
              ],
            ),
            textColor: theme.palette.onSurface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            onTap: () => context.push(
              app_paths.PLAYLIST_DETAIL_PAGE,
              extra: PLAYLISTS[i],
            ),
          ),
        ),
      ),
    );
  }

  IconButton removePlaylistBtn(int i, ThemeProvider theme) {
    return IconButton(
      onPressed: () => setState(() {
        PLAYLISTS.remove(PLAYLISTS[i]);
      }),
      hoverColor: theme.palette.error.withOpacity(0.08),
      highlightColor: theme.palette.error.withOpacity(0.12),
      splashColor: theme.palette.error.withOpacity(0.12),
      icon: Icon(
        Symbols.delete,
        color: theme.palette.error,
      ),
    );
  }

  IconButton editPlaylistBtn(BuildContext context, int i, ThemeProvider theme) {
    return IconButton(
      onPressed: () => editPlaylist(context, PLAYLISTS[i]),
      hoverColor: theme.palette.onSurface.withOpacity(0.08),
      highlightColor: theme.palette.onSurface.withOpacity(0.12),
      splashColor: theme.palette.onSurface.withOpacity(0.12),
      icon: Icon(
        Symbols.edit,
        color: theme.palette.onSurface,
      ),
    );
  }
}

class _NewPlaylistDialog extends StatelessWidget {
  const _NewPlaylistDialog({required this.theme});

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final editingController = TextEditingController();

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: theme.palette.surface,
      surfaceTintColor: theme.palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: 350.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "新建歌单",
                  style: TextStyle(
                    color: theme.palette.onSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextField(
                controller: editingController,
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
                cursorColor: theme.palette.primary,
                style: TextStyle(color: theme.palette.onSurface),
                decoration: theme.inputDecoration("歌单名称"),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        theme.palette.surface,
                      ),
                      foregroundColor: MaterialStatePropertyAll(
                        theme.palette.onSurface,
                      ),
                      overlayColor: MaterialStatePropertyAll(
                        theme.palette.onSurface.withOpacity(0.08),
                      ),
                    ),
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, editingController.text);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        theme.palette.surface,
                      ),
                      foregroundColor: MaterialStatePropertyAll(
                        theme.palette.onSurface,
                      ),
                      overlayColor: MaterialStatePropertyAll(
                        theme.palette.onSurface.withOpacity(0.08),
                      ),
                    ),
                    child: const Text("创建"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _EditPlaylistDialog extends StatelessWidget {
  const _EditPlaylistDialog({required this.theme});

  final ThemeProvider theme;

  @override
  Widget build(BuildContext context) {
    final editingController = TextEditingController();

    return Dialog(
      insetPadding: EdgeInsets.zero,
      backgroundColor: theme.palette.surface,
      surfaceTintColor: theme.palette.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: 350.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "修改歌单",
                  style: TextStyle(
                    color: theme.palette.onSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextField(
                controller: editingController,
                onSubmitted: (value) {
                  Navigator.pop(context, value);
                },
                cursorColor: theme.palette.primary,
                style: TextStyle(color: theme.palette.onSurface),
                decoration: theme.inputDecoration("新歌单名称"),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        theme.palette.surface,
                      ),
                      foregroundColor: MaterialStatePropertyAll(
                        theme.palette.onSurface,
                      ),
                      overlayColor: MaterialStatePropertyAll(
                        theme.palette.onSurface.withOpacity(0.08),
                      ),
                    ),
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, editingController.text);
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStatePropertyAll(
                        theme.palette.surface,
                      ),
                      foregroundColor: MaterialStatePropertyAll(
                        theme.palette.onSurface,
                      ),
                      overlayColor: MaterialStatePropertyAll(
                        theme.palette.onSurface.withOpacity(0.08),
                      ),
                    ),
                    child: const Text("创建"),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class PlaylistDetailPage extends StatefulWidget {
  const PlaylistDetailPage({super.key, required this.playlist});

  final Playlist playlist;

  @override
  State<PlaylistDetailPage> createState() => _PlaylistDetailPageState();
}

class _PlaylistDetailPageState extends State<PlaylistDetailPage> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return PageScaffold(
      title: widget.playlist.name,
      subtitle: "${widget.playlist.audios.length} 首乐曲",
      actions: [
        FilledButton.icon(
          onPressed: () {
            PlayService.instance.shuffleAndPlay(widget.playlist.audios);
          },
          icon: const Icon(Symbols.shuffle),
          label: const Text("随机播放"),
          style: theme.primaryButtonStyle,
        ),
      ],
      body: Material(
        type: MaterialType.transparency,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 96.0),
          itemCount: widget.playlist.audios.length,
          itemBuilder: (context, i) {
            return Stack(
              children: [
                AudioTile(audioIndex: i, playlist: widget.playlist.audios),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, right: 12.0),
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          widget.playlist.audios.removeAt(i);
                        });
                      },
                      icon: Icon(
                        Symbols.delete,
                        color: theme.palette.error,
                      ),
                      hoverColor: theme.palette.error.withOpacity(0.08),
                      highlightColor: theme.palette.error.withOpacity(0.12),
                      splashColor: theme.palette.error.withOpacity(0.12),
                    ),
                  ),
                )
              ],
            );
          },
        ),
      ),
    );
  }
}
