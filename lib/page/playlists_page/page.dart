import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

class PlaylistsPage extends StatefulWidget {
  const PlaylistsPage({super.key});

  @override
  State<PlaylistsPage> createState() => _PlaylistsPageState();
}

class _PlaylistsPageState extends State<PlaylistsPage> {
  void newPlaylist(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _NewPlaylistDialog(),
    );
    if (name == null) return;
    setState(() {
      PLAYLISTS.add(Playlist(name, []));
    });
  }

  void editPlaylist(
    BuildContext context,
    Playlist playlist,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => const _EditPlaylistDialog(),
    );
    if (name == null) return;
    setState(() {
      playlist.name = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return PageScaffold(
      title: "歌单",
      actions: [
        FilledButton.icon(
          onPressed: () => newPlaylist(context),
          icon: const Icon(Symbols.add),
          label: const Text("新建歌单"),
          style: const ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size.fromHeight(40)),
          ),
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
                IconButton(
                  onPressed: () => editPlaylist(context, PLAYLISTS[i]),
                  icon: const Icon(
                    Symbols.edit,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() {
                    PLAYLISTS.remove(PLAYLISTS[i]);
                  }),
                  color: scheme.error,
                  icon: const Icon(Symbols.delete),
                ),
              ],
            ),
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
}

class _NewPlaylistDialog extends StatelessWidget {
  const _NewPlaylistDialog();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editingController = TextEditingController();

    return Dialog(
      insetPadding: EdgeInsets.zero,
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
                    color: scheme.onSurface,
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
                decoration: const InputDecoration(
                  labelText: "歌单名称",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, editingController.text);
                    },
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
  const _EditPlaylistDialog();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final editingController = TextEditingController();

    return Dialog(
      insetPadding: EdgeInsets.zero,
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
                    color: scheme.onSurface,
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
                decoration: const InputDecoration(
                  labelText: "新歌单名称",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, editingController.text);
                    },
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
    final scheme = Theme.of(context).colorScheme;
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
          style: const ButtonStyle(
            fixedSize: WidgetStatePropertyAll(Size.fromHeight(40)),
          ),
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
                AudioTile(
                  audioIndex: i,
                  playlist: widget.playlist.audios,
                  action: IconButton(
                    onPressed: () {
                      setState(() {
                        widget.playlist.audios.removeAt(i);
                      });
                    },
                    color: scheme.error,
                    icon: const Icon(Symbols.delete),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
