import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/component/artist_tile.dart';
import 'package:coriander_player/utils.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final contentList = AudioLibrary.instance.artistCollection.values.toList();
    return UniPage<Artist>(
      pref: AppPreference.instance.artistsPagePref,
      title: "艺术家",
      subtitle: "${contentList.length} 位艺术家",
      contentList: contentList,
      contentBuilder: (_, item, __, multiSelectController) => ArtistTile(artist: item),
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
