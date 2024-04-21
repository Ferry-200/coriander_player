import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/page/uni_page_controller.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AudiosPage extends StatelessWidget {
  final Audio? locateTo;
  const AudiosPage({super.key, this.locateTo});

  @override
  Widget build(BuildContext context) {
    final contentList = List<Audio>.from(AudioLibrary.instance.audioCollection);
    return UniPage<Audio>(
      title: "音乐",
      subtitle: "${contentList.length} 首乐曲",
      contentList: contentList,
      contentBuilder: (context, item, i) => AudioTile(
        audioIndex: i,
        playlist: contentList,
        focus: item == locateTo,
      ),
      enableShufflePlay: true,
      enableSortMethod: true,
      enableSortOrder: true,
      enableContentViewSwitch: true,
      defaultContentView: ContentView.list,
      locateTo: locateTo,
      sortMethods: [
        SortMethodDesc(
          icon: Symbols.title,
          name: "标题",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.title.compareTo(b.title));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.title.compareTo(a.title));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.artist,
          name: "艺术家",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.artist.compareTo(b.artist));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.artist.compareTo(a.artist));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.album,
          name: "专辑",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.album.compareTo(b.album));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.album.compareTo(a.album));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.add,
          name: "创建时间",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.created.compareTo(b.created));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.created.compareTo(a.created));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.edit,
          name: "修改时间",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.modified.compareTo(b.modified));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.modified.compareTo(a.modified));
                break;
            }
          },
        ),
      ],
    );
  }
}
