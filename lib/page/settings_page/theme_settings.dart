import 'dart:io';
import 'package:coriander_player/src/rust/api/installed_font.dart';
import 'package:flutter/services.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/settings_tile.dart';
import 'package:coriander_player/page/settings_page/theme_picker_dialog.dart';
import 'package:coriander_player/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      description: "修改主题",
      action: FilledButton.icon(
        onPressed: () async {
          final seedColor = await showDialog<Color>(
            context: context,
            builder: (context) => const ThemePickerDialog(),
          );
          if (seedColor == null) return;

          ThemeProvider.instance.applyTheme(seedColor: seedColor);
          AppSettings.instance.defaultTheme = seedColor.value;
          await AppSettings.instance.saveSettings();
        },
        label: const Text("主题选择器"),
        icon: const Icon(Symbols.palette),
      ),
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
    return SettingsTile(
      description: "主题模式",
      action: SegmentedButton<ThemeMode>(
        showSelectedIcon: false,
        segments: const [
          ButtonSegment<ThemeMode>(
            value: ThemeMode.light,
            icon: Icon(Symbols.light_mode),
          ),
          ButtonSegment<ThemeMode>(
            value: ThemeMode.dark,
            icon: Icon(Symbols.dark_mode),
          ),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (newSelection) async {
          if (newSelection.first == settings.themeMode) return;

          setState(() {
            settings.themeMode = newSelection.first;
          });
          ThemeProvider.instance.applyThemeMode(settings.themeMode);
          await settings.saveSettings();
        },
      ),
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
    return SettingsTile(
      description: "动态主题",
      action: Switch(
        value: settings.dynamicTheme,
        onChanged: (_) async {
          setState(() {
            settings.dynamicTheme = !settings.dynamicTheme;
          });
          await settings.saveSettings();
        },
      ),
    );
  }
}

class UseSystemThemeSwitch extends StatefulWidget {
  const UseSystemThemeSwitch({super.key});

  @override
  State<UseSystemThemeSwitch> createState() => _UseSystemThemeSwitchState();
}

class _UseSystemThemeSwitchState extends State<UseSystemThemeSwitch> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      description: "启动时使用系统主题",
      action: Switch(
        value: settings.useSystemTheme,
        onChanged: (_) async {
          setState(() {
            settings.useSystemTheme = !settings.useSystemTheme;
          });
          await settings.saveSettings();
        },
      ),
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
    return SettingsTile(
      description: "启动时使用系统主题模式",
      action: Switch(
        value: settings.useSystemThemeMode,
        onChanged: (_) async {
          setState(() {
            settings.useSystemThemeMode = !settings.useSystemThemeMode;
          });
          await settings.saveSettings();
        },
      ),
    );
  }
}

class SelectFontCombobox extends StatelessWidget {
  const SelectFontCombobox({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      description: "自定义字体",
      action: FutureBuilder(
        future: getInstalledFonts(),
        builder: (context, snapshot) {
          final theme = Provider.of<ThemeProvider>(context);
          return switch (snapshot.connectionState) {
            ConnectionState.done => snapshot.data == null
                ? const Center(child: Text("不可用"))
                : DropdownMenu(
                    menuHeight: 400,
                    hintText: theme.fontFamily ?? "默认",
                    dropdownMenuEntries: snapshot.data!
                        .map((font) => DropdownMenuEntry(
                              value: font,
                              label: font.fullName,
                            ))
                        .toList(),
                    onSelected: (font) async {
                      if (font == null) return;

                      try {
                        final fontLoader = FontLoader(font.fullName);
                        fontLoader.addFont(
                          File(font.path).readAsBytes().then((value) {
                            return ByteData.sublistView(value);
                          }),
                        );
                        await fontLoader.load();
                        ThemeProvider.instance.changeFontFamily(font.fullName);

                        final settings = AppSettings.instance;
                        settings.fontFamily = font.fullName;
                        settings.fontPath = font.path;
                        await settings.saveSettings();
                      } catch (err) {
                        ThemeProvider.instance.changeFontFamily(null);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(err.toString())),
                          );
                        }
                      }
                    },
                  ),
            _ => const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(),
              ),
          };
        },
      ),
    );
  }
}
