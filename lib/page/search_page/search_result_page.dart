import 'package:coriander_player/component/album_tile.dart';
import 'package:coriander_player/component/artist_tile.dart';
import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:coriander_player/page/search_page/search_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;

class SearchResultPage extends StatefulWidget {
  const SearchResultPage({super.key, required this.searchResult});

  final UnionSearchResult searchResult;

  @override
  State<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends State<SearchResultPage> {
  late final searchResult = ValueNotifier(widget.searchResult);
  late final searchBarController = TextEditingController(
    text: widget.searchResult.query,
  );

  List<_SearchResultPageBody> buildContent(UnionSearchResult result) {
    return [
      _SearchResultPageBody(result: result, filter: _SearchResultFilter.all),
      _SearchResultPageBody(result: result, filter: _SearchResultFilter.music),
      _SearchResultPageBody(result: result, filter: _SearchResultFilter.artist),
      _SearchResultPageBody(result: result, filter: _SearchResultFilter.album),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ColoredBox(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: DefaultTabController(
          length: 4,
          child: Column(
            children: [
              Focus(
                onFocusChange: HotkeysHelper.onFocusChanges,
                child: Hero(
                  tag: SEARCH_BAR_KEY,
                  child: TextField(
                    controller: searchBarController,
                    decoration: const InputDecoration(
                      suffixIcon: Padding(
                        padding: EdgeInsets.only(right: 12.0),
                        child: Icon(Symbols.search),
                      ),
                      hintText: "搜索歌曲、艺术家、专辑",
                      border: OutlineInputBorder(),
                    ),

                    /// when 'enter' is pressed
                    onSubmitted: (String query) {
                      searchResult.value = UnionSearchResult.search(query);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8.0),
              Material(
                type: MaterialType.transparency,
                child: TabBar(
                  tabs: _SearchResultFilter.values
                      .map((filter) => Tab(text: filter.name))
                      .toList(),
                ),
              ),
              Expanded(
                child: Material(
                  type: MaterialType.transparency,
                  child: ValueListenableBuilder(
                    valueListenable: searchResult,
                    builder: (context, value, _) => TabBarView(
                      children: buildContent(value),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _SearchResultFilter {
  all("所有"),
  music("音乐"),
  artist("艺术家"),
  album("专辑");

  const _SearchResultFilter(this.name);
  final String name;
}

class _SearchResultPageBody extends StatelessWidget {
  const _SearchResultPageBody(
      {required this.result, required this.filter});

  final UnionSearchResult result;
  final _SearchResultFilter filter;

  Widget buildContentHeader(
    ColorScheme scheme,
    _SearchResultFilter contentType,
  ) {
    return SliverToBoxAdapter(
      child: filter == _SearchResultFilter.all
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                contentType.name,
                style: TextStyle(
                  color: scheme.onSurface,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : const SizedBox(height: 8.0),
    );
  }

  List<Widget> buildMusicResultContent(ColorScheme scheme) {
    return [
      buildContentHeader(scheme, _SearchResultFilter.music),
      SliverList.builder(
        itemCount: result.audios.length,
        itemBuilder: (context, i) {
          final item = result.audios[i];
          return AudioTile(
            audioIndex: 0,
            playlist: [item],
            action: IconButton(
              onPressed: () {
                context.push(app_paths.AUDIOS_PAGE, extra: item);
              },
              icon: const Icon(Symbols.location_on),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> buildArtistResultContent(ColorScheme scheme) {
    return [
      buildContentHeader(scheme, _SearchResultFilter.artist),
      SliverList.builder(
        itemCount: result.artists.length,
        itemBuilder: (context, i) => ArtistTile(artist: result.artists[i]),
      ),
    ];
  }

  List<Widget> buildAlbumResultContent(ColorScheme scheme) {
    return [
      buildContentHeader(scheme, _SearchResultFilter.album),
      SliverList.builder(
        itemCount: result.album.length,
        itemBuilder: (context, i) => AlbumTile(album: result.album[i]),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    List<Widget> slivers = [];
    switch (filter) {
      case _SearchResultFilter.all:
        if (result.audios.isNotEmpty) {
          slivers.addAll(buildMusicResultContent(scheme));
        }
        if (result.artists.isNotEmpty) {
          slivers.addAll(buildArtistResultContent(scheme));
        }
        if (result.album.isNotEmpty) {
          slivers.addAll(buildAlbumResultContent(scheme));
        }
        break;
      case _SearchResultFilter.music:
        slivers.addAll(buildMusicResultContent(scheme));
        break;
      case _SearchResultFilter.artist:
        slivers.addAll(buildArtistResultContent(scheme));
        break;
      case _SearchResultFilter.album:
        slivers.addAll(buildAlbumResultContent(scheme));
        break;
    }
    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)));
    return CustomScrollView(slivers: slivers);
  }
}
