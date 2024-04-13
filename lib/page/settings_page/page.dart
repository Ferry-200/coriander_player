import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:coriander_player/theme/color_palette.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      title: "设置",
      actions: const [],
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96.0),
        children: const [
          _AudioLibraryEditField(),
          SizedBox(height: 16.0),
          _ThemeModeControl(),
          SizedBox(height: 16.0),
          _DynamicThemeSwitch(),
          SizedBox(height: 16.0),
          _ThemeSelect(),
        ],
      ),
    );
  }
}

class _ThemeSelect extends StatefulWidget {
  const _ThemeSelect();

  @override
  State<_ThemeSelect> createState() => __ThemeSelectState();
}

class __ThemeSelectState extends State<_ThemeSelect> {
  final settings = AppSettings.instance;
  final themeCollection = [
    4292114089,
    4282283161,
    4286080703,
    4290765296,
    4287059351,
    4292356666,
    4293706294,
    ThemeProvider.instance.palette.seed,
  ];
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    themeCollection.last = theme.palette.seed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "默认主题色",
          style: TextStyle(
            color: theme.palette.onSurface,
            fontSize: 18.0,
          ),
        ),
        const SizedBox(height: 8.0),
        Wrap(
          spacing: 8.0,
          runSpacing: 8.0,
          children: List.generate(
            themeCollection.length,
            (i) {
              final themeItem = ColorPalette.fromSeed(
                seedValue: themeCollection[i],
                brightness: settings.themeMode,
              );
              return MouseRegion(
                child: GestureDetector(
                  onTap: () async {
                    setState(() {
                      settings.defaultTheme = themeCollection[i];
                    });
                    theme.changeTheme(themeItem);
                    await settings.saveSettings();
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 64.0,
                        height: 64.0,
                        decoration: BoxDecoration(
                          color: themeItem.primary,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: i == themeCollection.length - 1
                            ? Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "当前主题",
                                  style: TextStyle(color: themeItem.onPrimary),
                                ),
                              )
                            : const SizedBox(),
                      ),
                      settings.defaultTheme == themeCollection[i]
                          ? Icon(Symbols.check, color: themeItem.onPrimary)
                          : const SizedBox(),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

class _DynamicThemeSwitch extends StatefulWidget {
  const _DynamicThemeSwitch();

  @override
  State<_DynamicThemeSwitch> createState() => __DynamicThemeSwitchState();
}

class __DynamicThemeSwitchState extends State<_DynamicThemeSwitch> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "动态主题",
          style: TextStyle(
            color: theme.palette.onSurface,
            fontSize: 18.0,
          ),
        ),
        Switch(
          value: settings.dynamicTheme,
          onChanged: (_) async {
            setState(() {
              settings.dynamicTheme = !settings.dynamicTheme;
            });
            await settings.saveSettings();
          },
          hoverColor: theme.palette.onSurface.withOpacity(0.08),
          activeColor: theme.palette.primary,
          activeTrackColor: theme.palette.primaryContainer,
          inactiveThumbColor: theme.palette.outline,
          inactiveTrackColor: theme.palette.surfaceContainer,
          trackOutlineColor: MaterialStatePropertyAll(theme.palette.outline),
          trackOutlineWidth: const MaterialStatePropertyAll(1.0),
        ),
      ],
    );
  }
}

class _ThemeModeControl extends StatefulWidget {
  const _ThemeModeControl();

  @override
  State<_ThemeModeControl> createState() => __ThemeModeControlState();
}

class __ThemeModeControlState extends State<_ThemeModeControl> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "主题模式",
          style: TextStyle(
            color: theme.palette.onSurface,
            fontSize: 18.0,
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              color: theme.palette.outline,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: MouseRegion(
            cursor: MaterialStateMouseCursor.clickable,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    if (settings.themeMode == Brightness.light) return;

                    setState(() {
                      settings.themeMode = Brightness.light;
                    });
                    theme.toggleThemeMode();
                    await settings.saveSettings();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: settings.themeMode == Brightness.light
                          ? theme.palette.primary
                          : theme.palette.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16.0),
                        bottomLeft: Radius.circular(16.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Icon(
                        Symbols.light_mode,
                        color: settings.themeMode == Brightness.light
                            ? theme.palette.onPrimary
                            : theme.palette.onSurface,
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    if (settings.themeMode == Brightness.dark) return;

                    setState(() {
                      settings.themeMode = Brightness.dark;
                    });
                    theme.toggleThemeMode();
                    await settings.saveSettings();
                  },
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: settings.themeMode == Brightness.dark
                          ? theme.palette.primary
                          : theme.palette.surfaceContainer,
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(16.0),
                        bottomRight: Radius.circular(16.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: Icon(
                        Symbols.dark_mode,
                        color: settings.themeMode == Brightness.dark
                            ? theme.palette.onPrimary
                            : theme.palette.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _AudioLibraryEditField extends StatefulWidget {
  const _AudioLibraryEditField();

  @override
  State<_AudioLibraryEditField> createState() => __AudioLibraryEditFieldState();
}

class __AudioLibraryEditFieldState extends State<_AudioLibraryEditField> {
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
                  color: theme.palette.onSurface,
                  fontSize: 18.0,
                ),
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () async {
                      String? selectedDirectory =
                          await FilePicker.platform.getDirectoryPath();
                      if (selectedDirectory == null) return;
                      setState(() {
                        audioLibrary.folders.add(
                          AudioFolder([], selectedDirectory, 0),
                        );
                      });
                    },
                    hoverColor: theme.palette.onSurface.withOpacity(0.08),
                    highlightColor: theme.palette.onSurface.withOpacity(0.12),
                    splashColor: theme.palette.onSurface.withOpacity(0.12),
                    icon: Icon(
                      Symbols.add,
                      color: theme.palette.onSurface,
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
                (i) => _FolderChip(
                  audioFolder: audioLibrary.folders[i],
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
      hoverColor: theme.palette.onSurface.withOpacity(0.08),
      highlightColor: theme.palette.onSurface.withOpacity(0.12),
      splashColor: theme.palette.onSurface.withOpacity(0.12),
      icon: isLoading
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: theme.palette.primary,
                backgroundColor: theme.palette.surface,
              ),
            )
          : Icon(
              Symbols.refresh,
              color: theme.palette.onSurface,
            ),
    );
  }
}

class _FolderChip extends StatelessWidget {
  const _FolderChip({
    required this.audioFolder,
    required this.onDelete,
  });

  final AudioFolder audioFolder;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.palette.surface,
          border: Border.all(color: theme.palette.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                audioFolder.path,
                style: TextStyle(
                  color: theme.palette.onSurface,
                  fontSize: 16.0,
                ),
              ),
              IconButton(
                onPressed: onDelete,
                hoverColor: theme.palette.error.withOpacity(0.08),
                highlightColor: theme.palette.error.withOpacity(0.12),
                splashColor: theme.palette.error.withOpacity(0.12),
                icon: Icon(
                  Symbols.delete,
                  color: theme.palette.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
