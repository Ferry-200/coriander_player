import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';

class UnionSearchResult {
  String query;

  /// key: audio, value: position
  List<Audio> audios = [];
  List<Artist> artists = [];
  List<Album> album = [];

  UnionSearchResult(this.query);
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final editingController = TextEditingController();

  UnionSearchResult unionSearch() {
    final query = editingController.text;
    final result = UnionSearchResult(query);
    final library = AudioLibrary.instance;

    for (int i = 0; i < library.audioCollection.length; i++) {
      if (library.audioCollection[i].title.contains(query)) {
        result.audios.add(library.audioCollection[i]);
      }
    }

    for (Artist item in library.artistCollection.values) {
      if (item.name.contains(query)) {
        result.artists.add(item);
      }
    }

    for (Album item in library.albumCollection.values) {
      if (item.name.contains(query)) {
        result.album.add(item);
      }
    }

    return result;
  }

  void toUnionPage() {
    final result = unionSearch();
    context.push(
      app_paths.UNION_SEARCH_RESULT_PAGE,
      extra: result,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "搜索",
              style: TextStyle(
                color: theme.scheme.onSurface,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Padding(padding: EdgeInsets.only(bottom: 32.0)),
            SizedBox(
              width: 400,
              child: TextField(
                controller: editingController,

                /// when 'enter' is pressed
                onSubmitted: (_) => toUnionPage(),
                cursorColor: theme.scheme.primary,
                style: TextStyle(color: theme.scheme.onSurface),
                decoration: InputDecoration(
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: IconButton(
                      icon: const Icon(Symbols.search),
                      onPressed: toUnionPage,
                    ),
                  ),
                  suffixIconColor: theme.scheme.onSurface,
                  hintText: "搜索歌曲、艺术家、专辑",
                  hintStyle: TextStyle(
                    color: theme.scheme.onSurfaceVariant,
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.scheme.outline,
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: theme.scheme.primary,
                      width: 2.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    editingController.dispose();
  }
}
