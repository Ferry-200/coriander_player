import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class FoldersPage extends StatelessWidget {
  const FoldersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final library = AudioLibrary.instance;
    final theme = Provider.of<ThemeProvider>(context);

    return PageScaffold(
      title: "文件夹",
      actions: const [],
      body: Material(
        type: MaterialType.transparency,
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 96.0),
          itemCount: library.folders.length,
          itemBuilder: (context, i) {
            final folder = library.folders[i];
            return ListTile(
              title: Text(folder.path),
              subtitle: Text(
                "修改日期：${DateTime.fromMillisecondsSinceEpoch(folder.modified * 1000).toString()}",
              ),
              textColor: theme.palette.onSurface,
              hoverColor: theme.palette.onSurface.withOpacity(0.08),
              splashColor: theme.palette.onSurface.withOpacity(0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              onTap: () => context.push(
                app_paths.FOLDER_DETAIL_PAGE,
                extra: library.folders[i],
              ),
            );
          },
        ),
      ),
    );
  }
}

class FolderDetailPage extends StatelessWidget {
  const FolderDetailPage({super.key, required this.folder});

  final AudioFolder folder;

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: folder.path,
      actions: const [],
      body: Material(
        type: MaterialType.transparency,
        child: ListView.builder(
          itemCount: folder.audios.length,
          itemBuilder: (context, i) => AudioTile(
            audioIndex: i,
            playlist: folder.audios,
          ),
          padding: const EdgeInsets.only(bottom: 96.0),
        ),
      ),
    );
  }
}
