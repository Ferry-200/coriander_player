import 'dart:math';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:coriander_player/page/search_page/search_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UnionSearchResultPage extends StatelessWidget {
  const UnionSearchResultPage({super.key, required this.result});

  final UnionSearchResult result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final styleTitle = TextStyle(color: scheme.onSurface, fontSize: 18.0);
    final List<Widget> slivers = [
      SliverAppBar(
        automaticallyImplyLeading: false,
        title: Text("“${result.query}”的搜索结果"),
      )
    ];
    if (result.audios.isNotEmpty) {
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text("歌曲：", style: styleTitle),
        ),
      ));
      slivers.add(
        SliverList.builder(
          itemCount: min(3, result.audios.length),
          itemBuilder: (context, i) {
            return ListTile(
              title: Text(result.audios[i].title),
              subtitle: Text(
                  "${result.audios[i].artist} - ${result.audios[i].album}"),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onTap: () {
                context.push(app_paths.AUDIOS_PAGE, extra: result.audios[i]);
              },
            );
          },
        ),
      );
    }
    if (result.audios.length > 3) {
      slivers.add(SliverToBoxAdapter(
        child: ListTile(
          title: const Text("查看更多"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onTap: () {
            context.push(
              app_paths.AUDIO_SEARCH_RESULT_PAGE,
              extra: result.audios,
            );
          },
        ),
      ));
    }

    if (result.artists.isNotEmpty) {
      slivers.add(const SliverToBoxAdapter(child: Divider()));
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text("艺术家：", style: styleTitle),
        ),
      ));
      slivers.add(
        SliverList.builder(
          itemCount: min(3, result.artists.length),
          itemBuilder: (context, i) {
            final artist = result.artists[i];
            return ListTile(
              title: Text(artist.name),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onTap: () {
                context.push(app_paths.ARTIST_DETAIL_PAGE, extra: artist);
              },
            );
          },
        ),
      );
    }
    if (result.artists.length > 3) {
      slivers.add(SliverToBoxAdapter(
        child: ListTile(
          title: const Text("查看更多"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onTap: () {
            context.push(
              app_paths.ARTIST_SEARCH_RESULT_PAGE,
              extra: result.artists,
            );
          },
        ),
      ));
    }

    if (result.album.isNotEmpty) {
      slivers.add(const SliverToBoxAdapter(child: Divider()));
      slivers.add(SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text("专辑：", style: styleTitle),
        ),
      ));
      slivers.add(
        SliverList.builder(
          itemCount: min(3, result.album.length),
          itemBuilder: (context, i) {
            final album = result.album[i];
            return ListTile(
              title: Text(album.name),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onTap: () {
                context.push(app_paths.ALBUM_DETAIL_PAGE, extra: album);
              },
            );
          },
        ),
      );
    }
    if (result.album.length > 3) {
      slivers.add(SliverToBoxAdapter(
        child: ListTile(
          title: const Text("查看更多"),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          onTap: () {
            context.push(
              app_paths.ALBUM_SEARCH_RESULT_PAGE,
              extra: result.album,
            );
          },
        ),
      ));
    }

    slivers.add(const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)));

    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
        child: CustomScrollView(
          slivers: slivers,
        ),
      ),
    );
  }
}
