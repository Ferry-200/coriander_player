import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;

class AlbumTile extends StatelessWidget {
  const AlbumTile({
    super.key,
    required this.album,
  });

  final Album album;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: () => context.push(
        app_paths.ALBUM_DETAIL_PAGE,
        extra: album,
      ),
      borderRadius: BorderRadius.circular(8.0),
      hoverColor: theme.palette.onSurface.withOpacity(0.08),
      highlightColor: theme.palette.onSurface.withOpacity(0.12),
      splashColor: theme.palette.onSurface.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            FutureBuilder(
              future: album.works.first.cover,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Icon(
                    Symbols.broken_image,
                    color: theme.palette.onSurface,
                    size: 48,
                  );
                }
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image(
                    image: snapshot.data!,
                    width: 48.0,
                    height: 48.0,
                  ),
                );
              },
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  album.name,
                  style: TextStyle(
                    color: theme.palette.onSurface,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
