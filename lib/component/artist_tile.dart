import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;

class ArtistTile extends StatelessWidget {
  const ArtistTile({
    super.key,
    required this.artist,
  });

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return InkWell(
      onTap: () => context.push(
        app_paths.ARTIST_DETAIL_PAGE,
        extra: artist,
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
              future: artist.works.first.cover,
              builder: (context, snapshot) {
                if (snapshot.data == null) {
                  return Icon(
                    Symbols.broken_image,
                    color: theme.palette.onSurface,
                    size: 48,
                  );
                }
                return ClipOval(
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
                  artist.name,
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