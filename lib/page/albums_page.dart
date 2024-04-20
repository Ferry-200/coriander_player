import 'package:coriander_player/component/album_tile.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/page/uni_page_controller.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AlbumsPage extends StatelessWidget {
  const AlbumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentList = AudioLibrary.instance.albumCollection.values.toList();
    return UniPage<Album>(
      title: "专辑",
      subtitle: "${contentList.length} 张专辑",
      contentList: contentList,
      contentBuilder: (context, item, i) => AlbumTile(album: item),
      enableShufflePlay: false,
      enableSortBy: true,
      enableSortOrder: true,
      enableContentViewSwitch: true,
      defaultContentView: ContentView.table,
      sortMethods: [
        SortMethodDesc(
          icon: Symbols.title,
          name: "标题",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.name.compareTo(b.name));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.name.compareTo(a.name));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.music_note,
          name: "作品数量",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.works.length.compareTo(b.works.length));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.works.length.compareTo(a.works.length));
                break;
            }
          },
        ),
      ],
    );
  }
}
