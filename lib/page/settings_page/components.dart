import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:coriander_player/theme/color_palette.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github/github.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UseSystemThemeSwitch extends StatefulWidget {
  const UseSystemThemeSwitch({super.key});

  @override
  State<UseSystemThemeSwitch> createState() => _UseSystemThemeSwitchState();
}

class _UseSystemThemeSwitchState extends State<UseSystemThemeSwitch> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "启动时使用系统主题",
          style: TextStyle(
            color: theme.palette.onSurface,
            fontSize: 18.0,
          ),
        ),
        Switch(
          value: settings.useSystemTheme,
          onChanged: (_) async {
            setState(() {
              settings.useSystemTheme = !settings.useSystemTheme;
            });
            await settings.saveSettings();
          },
        ),
      ],
    );
  }
}

class UseSystemThemeModeSwitch extends StatefulWidget {
  const UseSystemThemeModeSwitch({super.key});

  @override
  State<UseSystemThemeModeSwitch> createState() =>
      _UseSystemThemeModeSwitchState();
}

class _UseSystemThemeModeSwitchState extends State<UseSystemThemeModeSwitch> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "启动时使用系统主题模式",
          style: TextStyle(
            color: theme.palette.onSurface,
            fontSize: 18.0,
          ),
        ),
        Switch(
          value: settings.useSystemThemeMode,
          onChanged: (_) async {
            setState(() {
              settings.useSystemThemeMode = !settings.useSystemThemeMode;
            });
            await settings.saveSettings();
          },
        ),
      ],
    );
  }
}

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
        ? theme.palette.onSecondaryContainer
        : theme.palette.onSurface;
    final rightForeColor = !settings.localLyricFirst
        ? theme.palette.onSecondaryContainer
        : theme.palette.onSurface;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "首选歌词来源",
          style: TextStyle(
            color: theme.palette.onSurface,
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

class CheckForUpdate extends StatefulWidget {
  const CheckForUpdate({super.key});

  @override
  State<CheckForUpdate> createState() => _CheckForUpdateState();
}

class _CheckForUpdateState extends State<CheckForUpdate> {
  bool isChecking = false;
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final List<Widget> children = [
      FilledButton.icon(
        icon: const Icon(Symbols.update),
        label: const Text("检查更新"),
        onPressed: isChecking
            ? null
            : () async {
                setState(() {
                  isChecking = true;
                });

                final newest = await AppSettings.github.repositories
                    .listReleases(
                        RepositorySlug("Ferry-200", "coriander_player"))
                    .first;
                final newestVer = int.tryParse(
                      newest.tagName?.substring(1).replaceAll(".", "") ?? "",
                    ) ??
                    0;
                final currVer =
                    int.tryParse(AppSettings.version.replaceAll(".", "")) ?? 0;
                if (newestVer > currVer) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => NewestUpdateView(release: newest),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "无新版本",
                        style: TextStyle(color: theme.palette.onSecondary),
                      ),
                      backgroundColor: theme.palette.secondary,
                    ));
                  }
                }

                setState(() {
                  isChecking = false;
                });
              },
        style: theme.primaryButtonStyle,
      ),
    ];
    if (isChecking) {
      children.add(const SizedBox(width: 16.0));
      children.add(SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(
          color: theme.palette.primary,
          backgroundColor: theme.palette.primaryContainer,
        ),
      ));
    }
    return Material(
      type: MaterialType.transparency,
      child: Row(
        children: children,
      ),
    );
  }
}

class NewestUpdateView extends StatelessWidget {
  const NewestUpdateView({
    super.key,
    required this.release,
  });

  final Release release;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final textButtonStyle = ButtonStyle(
      overlayColor: MaterialStatePropertyAll(
        theme.palette.onSurface.withOpacity(0.08),
      ),
      foregroundColor: MaterialStatePropertyAll(theme.palette.onSurface),
    );
    final onSurface = TextStyle(color: theme.palette.onSurface);
    final onSurfaceVariant = TextStyle(color: theme.palette.onSurfaceVariant);
    final primary = TextStyle(
      color: theme.palette.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.palette.primary,
    );
    return Dialog(
      backgroundColor: theme.palette.surface,
      surfaceTintColor: theme.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    release.name ?? "新版本",
                    style: TextStyle(
                      color: theme.palette.onSurface,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    "${release.tagName}\n${release.publishedAt}",
                    style: TextStyle(color: theme.palette.onSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Markdown(
                data: release.body ?? "",
                onTapLink: (text, href, title) {
                  if (href != null) {
                    launchUrlString(href);
                  }
                },
                padding: EdgeInsets.zero,
                styleSheet: MarkdownStyleSheet(
                  a: primary,
                  p: onSurface,
                  code: onSurfaceVariant,
                  h1: onSurface,
                  h2: onSurface,
                  h3: onSurface,
                  h4: onSurface,
                  h5: onSurface,
                  h6: onSurface,
                  em: onSurface,
                  strong: onSurface,
                  del: onSurfaceVariant,
                  blockquote: onSurfaceVariant,
                  img: onSurface,
                  checkbox: onSurface,
                  listBullet: onSurface,
                  tableHead: onSurface,
                  tableBody: onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: textButtonStyle,
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 16.0),
                  TextButton.icon(
                    onPressed: () {
                      if (release.htmlUrl != null) {
                        launchUrlString(release.htmlUrl!);
                      }

                      Navigator.pop(context);
                    },
                    style: textButtonStyle,
                    icon: const Icon(Symbols.arrow_outward),
                    label: const Text("获取更新"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeSelector extends StatefulWidget {
  const ThemeSelector({super.key});

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
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
                cursor: MaterialStateMouseCursor.clickable,
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

class DynamicThemeSwitch extends StatefulWidget {
  const DynamicThemeSwitch({super.key});

  @override
  State<DynamicThemeSwitch> createState() => _DynamicThemeSwitchState();
}

class _DynamicThemeSwitchState extends State<DynamicThemeSwitch> {
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
        ),
      ],
    );
  }
}

class ThemeModeControl extends StatefulWidget {
  const ThemeModeControl({super.key});

  @override
  State<ThemeModeControl> createState() => _ThemeModeControlState();
}

class _ThemeModeControlState extends State<ThemeModeControl> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final leftForeColor = settings.themeMode == Brightness.light
        ? theme.palette.onSecondaryContainer
        : theme.palette.onSurface;
    final rightForeColor = settings.themeMode == Brightness.dark
        ? theme.palette.onSecondaryContainer
        : theme.palette.onSurface;

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
        SegmentedButton<Brightness>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment<Brightness>(
              value: Brightness.light,
              icon: Icon(Symbols.light_mode, color: leftForeColor),
            ),
            ButtonSegment<Brightness>(
              value: Brightness.dark,
              icon: Icon(Symbols.dark_mode, color: rightForeColor),
            ),
          ],
          selected: {settings.themeMode},
          onSelectionChanged: (newSelection) {
            if (newSelection.first == settings.themeMode) return;

            setState(() {
              settings.themeMode = newSelection.first;
            });
            theme.toggleThemeMode();
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
