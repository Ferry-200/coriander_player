import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/folder_tile.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:coriander_player/src/rust/api/utils.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DefaultLyricSourceControl extends StatefulWidget {
  const DefaultLyricSourceControl({super.key});

  @override
  State<DefaultLyricSourceControl> createState() =>
      _DefaultLyricSourceControlState();
}

class _DefaultLyricSourceControlState extends State<DefaultLyricSourceControl> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final leftForeColor = settings.localLyricFirst
        ? theme.scheme.onSecondaryContainer
        : theme.scheme.onSurface;
    final rightForeColor = !settings.localLyricFirst
        ? theme.scheme.onSecondaryContainer
        : theme.scheme.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "首选歌词来源",
          style: TextStyle(
            color: theme.scheme.onSurface,
            fontSize: 18.0,
          ),
        ),
        SegmentedButton<bool>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment<bool>(
              value: true,
              icon: Icon(Symbols.cloud_off, color: leftForeColor),
              label: Text(
                "本地",
                style: TextStyle(color: leftForeColor),
              ),
            ),
            ButtonSegment<bool>(
              value: false,
              icon: Icon(Symbols.cloud, color: rightForeColor),
              label: Text(
                "在线",
                style: TextStyle(color: rightForeColor),
              ),
            ),
          ],
          selected: {settings.localLyricFirst},
          onSelectionChanged: (newSelection) {
            if (newSelection.first == settings.localLyricFirst) return;

            setState(() {
              settings.localLyricFirst = newSelection.first;
            });
            settings.saveSettings();
          },
        ),
      ],
    );
  }
}

class AudioLibraryEditField extends StatefulWidget {
  const AudioLibraryEditField({super.key});

  @override
  State<AudioLibraryEditField> createState() => _AudioLibraryEditFieldState();
}

class _AudioLibraryEditFieldState extends State<AudioLibraryEditField> {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final audioLibrary = AudioLibrary.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "文件夹管理",
                style: TextStyle(
                  color: theme.scheme.onSurface,
                  fontSize: 18.0,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      String? selectedDirectory = await pickSingleFolder();
                      if (selectedDirectory == null) return;
                      setState(() {
                        audioLibrary.folders.add(
                          AudioFolder([], selectedDirectory, 0),
                        );
                      });
                    },
                    hoverColor: theme.scheme.onSurface.withOpacity(0.08),
                    highlightColor: theme.scheme.onSurface.withOpacity(0.12),
                    splashColor: theme.scheme.onSurface.withOpacity(0.12),
                    icon: Icon(
                      Symbols.add,
                      color: theme.scheme.onSurface,
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  const _BuildIndexButton(),
                ],
              ),
            ],
          ),
        ),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 250.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                audioLibrary.folders.length,
                (i) => FolderTile(
                  path: audioLibrary.folders[i].path,
                  onDelete: () {
                    setState(() {
                      audioLibrary.folders.removeAt(i);
                    });
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _BuildIndexButton extends StatefulWidget {
  const _BuildIndexButton();

  @override
  State<_BuildIndexButton> createState() => __BuildIndexButtonState();
}

class __BuildIndexButtonState extends State<_BuildIndexButton> {
  var isLoading = false;

  void save() async {
    final audioLibrary = AudioLibrary.instance;
    setState(() {
      isLoading = true;
    });
    final indexPath = (await getApplicationSupportDirectory()).path;
    await buildIndexFromPaths(
      paths: List.generate(
        audioLibrary.folders.length,
        (i) => audioLibrary.folders[i].path,
      ),
      indexPath: indexPath,
    );
    await AudioLibrary.initFromIndex();
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return IconButton(
      onPressed: isLoading ? null : save,
      hoverColor: theme.scheme.onSurface.withOpacity(0.08),
      highlightColor: theme.scheme.onSurface.withOpacity(0.12),
      splashColor: theme.scheme.onSurface.withOpacity(0.12),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: theme.scheme.primary,
                backgroundColor: theme.scheme.surface,
              ),
            )
          : Icon(
              Symbols.refresh,
              color: theme.scheme.onSurface,
            ),
    );
  }
}