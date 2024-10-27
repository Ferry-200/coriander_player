import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/utils.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

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
      PLAYLISTS.add(Playlist(name, {}));
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

    return UniPage<Playlist>(
      pref: AppPreference.instance.playlistsPagePref,
      title: "歌单",
      subtitle: "${PLAYLISTS.length} 个歌单",
      contentList: PLAYLISTS,
      contentBuilder: (context, item, i, multiSelectController) => ListTile(
        title: Text(
          PLAYLISTS[i].name,
          softWrap: false,
          maxLines: 1,
        ),
        subtitle: Text(
          "${PLAYLISTS[i].audios.length}首乐曲",
          softWrap: false,
          maxLines: 1,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: "编辑",
              onPressed: () => editPlaylist(context, PLAYLISTS[i]),
              icon: const Icon(Symbols.edit),
            ),
            const SizedBox(width: 8.0),
            IconButton(
              tooltip: "删除",
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
      primaryAction: FilledButton.icon(
        onPressed: () => newPlaylist(context),
        icon: const Icon(Symbols.add),
        label: const Text("新建歌单"),
        style: const ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size.fromHeight(40)),
        ),
      ),
      enableShufflePlay: false,
      enableSortMethod: true,
      enableSortOrder: true,
      enableContentViewSwitch: true,
      sortMethods: [
        SortMethodDesc(
          icon: Symbols.title,
          name: "名称",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.name.localeCompareTo(b.name));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.name.localeCompareTo(a.name));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.music_note,
          name: "歌曲数量",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.audios.length.compareTo(b.audios.length));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.audios.length.compareTo(a.audios.length));
                break;
            }
          },
        ),
      ],
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Focus(
                onFocusChange: HotkeysHelper.onFocusChanges,
                child: TextField(
                  autofocus: true,
                  controller: editingController,
                  onSubmitted: (value) {
                    Navigator.pop(context, value);
                  },
                  decoration: const InputDecoration(
                    labelText: "歌单名称",
                    border: OutlineInputBorder(),
                  ),
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
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Focus(
                onFocusChange: HotkeysHelper.onFocusChanges,
                child: TextField(
                  autofocus: true,
                  controller: editingController,
                  onSubmitted: (value) {
                    Navigator.pop(context, value);
                  },
                  decoration: const InputDecoration(
                    labelText: "新歌单名称",
                    border: OutlineInputBorder(),
                  ),
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
