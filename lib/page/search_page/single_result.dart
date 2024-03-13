import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class AudioSearchResultPage extends StatelessWidget {
  const AudioSearchResultPage({super.key, required this.result});

  final List<MapEntry<Audio, int>> result;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Material(
      color: theme.palette.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: const Text("搜索结果"),
              backgroundColor: theme.palette.surface,
              foregroundColor: theme.palette.onSurface,
            ),
            SliverList.builder(
              itemCount: result.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(result[i].key.title),
                  subtitle:
                      Text("${result[i].key.artist} - ${result[i].key.album}"),
                  textColor: theme.palette.onSurface,
                  hoverColor: theme.palette.onSurface.withOpacity(0.08),
                  splashColor: theme.palette.onSurface.withOpacity(0.12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  onTap: () {
                    context.push("/audios?target=${result[i].value}");
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
    final theme = Provider.of<ThemeProvider>(context);

    return Material(
      color: theme.palette.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: const Text("搜索结果"),
              backgroundColor: theme.palette.surface,
              foregroundColor: theme.palette.onSurface,
            ),
            SliverList.builder(
              itemCount: result.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(result[i].name),
                  textColor: theme.palette.onSurface,
                  hoverColor: theme.palette.onSurface.withOpacity(0.08),
                  splashColor: theme.palette.onSurface.withOpacity(0.12),
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
    final theme = Provider.of<ThemeProvider>(context);

    return Material(
      color: theme.palette.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      clipBehavior: Clip.hardEdge,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              automaticallyImplyLeading: false,
              title: const Text("搜索结果"),
              backgroundColor: theme.palette.surface,
              foregroundColor: theme.palette.onSurface,
            ),
            SliverList.builder(
              itemCount: result.length,
              itemBuilder: (context, i) {
                return ListTile(
                  title: Text(result[i].name),
                  textColor: theme.palette.onSurface,
                  hoverColor: theme.palette.onSurface.withOpacity(0.08),
                  splashColor: theme.palette.onSurface.withOpacity(0.12),
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
