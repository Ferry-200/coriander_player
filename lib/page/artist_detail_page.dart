import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:coriander_player/page/uni_detail_page.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class ArtistDetailPage extends StatelessWidget {
  const ArtistDetailPage({super.key, required this.artist});

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final secondaryContent = List<Audio>.from(artist.works);
    return UniDetailPage<Artist, Audio, Album>(
      primaryContent: artist,
      primaryPic: artist.picture,
      picShape: PicShape.oval,
      title: artist.name,
      subtitle: "${artist.works.length} 首作品",
      secondaryContent: secondaryContent,
      secondaryContentBuilder: (context, audio, i) => AudioTile(
        audioIndex: i,
        playlist: secondaryContent,
      ),
      tertiaryContentTitle: "专辑",
      tertiaryContent: artist.albumsMap.values.toList(),
      tertiaryContentBuilder: (context, album, i) => ListTile(
        onTap: () => context.push(app_paths.ALBUM_DETAIL_PAGE, extra: album),
        title: Text(album.name),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      enableShufflePlay: true,
      enableSortMethod: true,
      enableSortOrder: true,
      enableSecondaryContentViewSwitch: true,
      defaultSecondaryContentView: ContentView.list,
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