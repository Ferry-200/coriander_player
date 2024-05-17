import 'dart:io';

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/folder_tile.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/component/title_bar.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:coriander_player/src/rust/api/utils.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class WelcomingPage extends StatelessWidget {
  const WelcomingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: theme.scheme.surface,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: _TitleBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "你的音乐都在哪些文件夹呢？",
              style: TextStyle(
                color: theme.scheme.onSurface,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 32.0),
            const _AudioFolderEdit(),
          ],
        ),
      ),
    );
  }
}

class _AudioFolderEdit extends StatefulWidget {
  const _AudioFolderEdit();

  @override
  State<_AudioFolderEdit> createState() => __AudioFolderEditState();
}

class __AudioFolderEditState extends State<_AudioFolderEdit> {
  final List<String> folderPaths = [];

  void _deletePath(int i) {
    setState(() {
      folderPaths.removeAt(i);
    });
  }

  void _addPath() async {
    String? selectedDirectory = await pickSingleFolder();
    if (selectedDirectory == null) return;
    setState(() {
      folderPaths.add(selectedDirectory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 300.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                folderPaths.length,
                (i) => FolderTile(
                  path: folderPaths[i],
                  onDelete: () => _deletePath(i),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16.0),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _addPath,
              icon: const Icon(Symbols.create_new_folder),
              label: const Text("添加"),
              style: theme.secondaryButtonStyle,
            ),
            const SizedBox(width: 8.0),
            FilledButton.icon(
              onPressed: () async {
                String? selectedDirectory = await pickSingleFolder();
                if (selectedDirectory == null) return;
                final dirs = Directory(selectedDirectory)
                    .listSync()
                    .where(
                      (element) =>
                          element.statSync().type ==
                          FileSystemEntityType.directory,
                    )
                    .map((e) => e.path);
                setState(() {
                  folderPaths.addAll(dirs);
                });
              },
              icon: const Icon(Symbols.folder),
              label: const Text("从父文件夹中添加路径"),
              style: theme.secondaryButtonStyle,
            ),
            const SizedBox(width: 8.0),
            _SaveButton(folderPaths: folderPaths),
          ],
        )
      ],
    );
  }
}

class _SaveButton extends StatefulWidget {
  const _SaveButton({required this.folderPaths});

  final List<String> folderPaths;

  @override
  State<_SaveButton> createState() => __SaveButtonState();
}

class __SaveButtonState extends State<_SaveButton> {
  bool isSaving = false;

  void save() async {
    setState(() {
      isSaving = true;
    });
    final indexPath = (await getApplicationSupportDirectory()).path;
    await buildIndexFromPaths(paths: widget.folderPaths, indexPath: indexPath);
    await AppSettings.instance.saveSettings();
    await AudioLibrary.initFromIndex();
    setState(() {
      isSaving = false;
    });
    
    final ctx = context;
    if (ctx.mounted) {
      ctx.go(app_paths.AUDIOS_PAGE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return FilledButton.icon(
      onPressed: isSaving ? null : save,
      icon: isSaving
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: theme.scheme.primary,
                backgroundColor: theme.scheme.primaryContainer,
              ),
            )
          : const Icon(Symbols.save),
      label: const Text("保存"),
      style: theme.primaryButtonStyle,
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return DragToMoveArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 4.0, 4.0, 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: 284.0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Symbols.music_note,
                      color: theme.scheme.onSurface,
                      size: 24.0,
                    ),
                    const SizedBox(width: 8.0),
                    Text(
                      "Coriander Player",
                      style: TextStyle(
                        color: theme.scheme.onSurface,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const WindowControlls(),
          ],
        ),
      ),
    );
  }
}
