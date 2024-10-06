import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/utils.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:coriander_player/page/uni_detail_page.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:coriander_player/page/uni_page_components.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key, required this.album});

  final Album album;

  @override
  Widget build(BuildContext context) {
    final secondaryContent = List<Audio>.from(album.works);
    final multiSelectController = MultiSelectController<Audio>();

    return UniDetailPage<Album, Audio, Artist>(
      pref: AppPreference.instance.albumDetailPagePref,
      primaryContent: album,
      primaryPic: album.cover,
      backgroundPic: album.works.first.cover,
      picShape: PicShape.rrect,
      title: album.name,
      subtitle: "${album.works.length} 首作品",
      secondaryContent: secondaryContent,
      secondaryContentBuilder: (context, audio, i, multiSelectController) => AudioTile(
        leading: Text(audio.track < 10 ? "0${audio.track}" : "${audio.track}"),
        audioIndex: i,
        playlist: secondaryContent,
        multiSelectController: multiSelectController,
      ),
      tertiaryContentTitle: "艺术家",
      tertiaryContent: album.artistsMap.values.toList(),
      tertiaryContentBuilder: (context, artist, i, multiSelectController) => ListTile(
        onTap: () => context.push(app_paths.ARTIST_DETAIL_PAGE, extra: artist),
        title: Text(artist.name),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      enableShufflePlay: true,
      enableSortMethod: true,
      enableSortOrder: true,
      enableSecondaryContentViewSwitch: true,
      multiSelectController: multiSelectController,
      multiSelectViewActions: [
        AddAllToPlaylist(multiSelectController: multiSelectController),
        MultiSelectSelectOrClearAll(
          multiSelectController: multiSelectController,
          contentList: secondaryContent,
        ),
        MultiSelectExit(multiSelectController: multiSelectController),
      ],
      sortMethods: [
        SortMethodDesc(
          icon: Symbols.title,
          name: "标题",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.title.localeCompareTo(b.title));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.title.localeCompareTo(a.title));
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
                list.sort((a, b) => a.artist.localeCompareTo(b.artist));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.artist.localeCompareTo(a.artist));
                break;
            }
          },
        ),
        SortMethodDesc(
          icon: Symbols.art_track,
          name: "音轨",
          method: (list, order) {
            switch (order) {
              case SortOrder.ascending:
                list.sort((a, b) => a.track.compareTo(b.track));
                break;
              case SortOrder.decending:
                list.sort((a, b) => b.track.compareTo(a.track));
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