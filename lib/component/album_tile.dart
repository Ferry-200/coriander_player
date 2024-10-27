import 'package:coriander_player/library/audio_library.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;

class AlbumTile extends StatelessWidget {
  const AlbumTile({
    super.key,
    required this.album,
  });

  final Album album;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final placeholder = Icon(
      Symbols.broken_image,
      size: 48,
      color: scheme.onSurface,
    );
    return Tooltip(
      message: album.name,
      child: InkWell(
        onTap: () => context.push(app_paths.ALBUM_DETAIL_PAGE, extra: album),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              FutureBuilder(
                future: album.works.first.cover,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return placeholder;
                  }
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image(
                      image: snapshot.data!,
                      width: 48.0,
                      height: 48.0,
                      errorBuilder: (_, __, ___) => placeholder,
                    ),
                  );
                },
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    album.name,
                    softWrap: false,
                    maxLines: 2,
                    style: TextStyle(color: scheme.onSurface),
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
