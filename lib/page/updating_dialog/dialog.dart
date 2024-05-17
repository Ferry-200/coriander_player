import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

/// 常规启动时，读取并更新索引
Future<void> initAudioLibrary() async {
  final indexPath = (await getApplicationSupportDirectory()).path;
  await updateIndex(indexPath: indexPath);
  await AudioLibrary.initFromIndex();
}

class UpdatingDialog extends StatefulWidget {
  const UpdatingDialog({super.key});

  @override
  State<UpdatingDialog> createState() => _UpdatingDialogState();
}

class _UpdatingDialogState extends State<UpdatingDialog> {
  late final Future<void> updateFuture;
  @override
  void initState() {
    super.initState();
    updateFuture = Future.wait([initAudioLibrary(), readPlaylists(), readLyricSources()]);
    updateFuture.whenComplete(() {
      context.go(app_paths.AUDIOS_PAGE);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scheme.surface,
      body: SimpleDialog(
        title: const Text("正在更新数据库"),
        titleTextStyle: TextStyle(color: theme.scheme.onSurface),
        elevation: 4,
        shadowColor: Colors.black,
        backgroundColor: theme.scheme.surface,
        surfaceTintColor: theme.scheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        children: [
          Center(
            child: FutureBuilder(
              future: updateFuture,
              builder: (context, snapshot) => CircularProgressIndicator(
                backgroundColor: theme.scheme.primaryContainer,
                color: theme.scheme.primary,
              ),
            ),
          )
        ],
      ),
    );
  }
}
