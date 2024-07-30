import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AudioSearchResultPage extends StatelessWidget {
  const AudioSearchResultPage({super.key, required this.result});

  final List<Audio> result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          slivers: [
            const SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text("搜索结果"),
            ),
            SliverList.builder(
              itemCount: result.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(
                    result[i].title,
                    maxLines: 1,
                  ),
                  subtitle: Text(
                    "${result[i].artist} - ${result[i].album}",
                    maxLines: 2,
                  ),
                  isThreeLine: true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  onTap: () {
                    context.push(app_paths.AUDIOS_PAGE, extra: result[i]);
                  },
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
          ],
        ),
      ),
    );
  }
}

class ArtistSearchResultPage extends StatelessWidget {
  const ArtistSearchResultPage({super.key, required this.result});

  final List<Artist> result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          slivers: [
            const SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text("搜索结果"),
            ),
            SliverList.builder(
              itemCount: result.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(result[i].name, maxLines: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  onTap: () {
                    context.push(
                      app_paths.ARTIST_DETAIL_PAGE,
                      extra: result[i],
                    );
                  },
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
          ],
        ),
      ),
    );
  }
}

class AlbumSearchResultPage extends StatelessWidget {
  const AlbumSearchResultPage({super.key, required this.result});

  final List<Album> result;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          slivers: [
            const SliverAppBar(
              automaticallyImplyLeading: false,
              title: Text("搜索结果"),
            ),
            SliverList.builder(
              itemCount: result.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(result[i].name, maxLines: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  onTap: () {
                    context.push(app_paths.ALBUM_DETAIL_PAGE, extra: result[i]);
                  },
                );
              },
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
          ],
        ),
      ),
    );
  }
}
