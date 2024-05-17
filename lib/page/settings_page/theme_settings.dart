import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

// class ThemeSelector extends StatefulWidget {
//   const ThemeSelector({super.key});

//   @override
//   State<ThemeSelector> createState() => _ThemeSelectorState();
// }

// class _ThemeSelectorState extends State<ThemeSelector> {
//   final settings = AppSettings.instance;
//   final themeCollection = [
//     4292114089,
//     4282283161,
//     4286080703,
//     4290765296,
//     4287059351,
//     4292356666,
//     4293706294,
//     ThemeProvider.instance.scheme.seed,
//   ];
//   @override
//   Widget build(BuildContext context) {
//     final theme = Provider.of<ThemeProvider>(context);
//     themeCollection.last = theme.scheme.seed;

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "默认主题色",
//           style: TextStyle(
//             color: theme.scheme.onSurface,
//             fontSize: 18.0,
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         Wrap(
//           spacing: 8.0,
//           runSpacing: 8.0,
//           children: List.generate(
//             themeCollection.length,
//             (i) {
//               final themeItem = ColorPalette.fromSeed(
//                 seedValue: themeCollection[i],
//                 brightness: settings.themeMode,
//               );
//               return MouseRegion(
//                 cursor: WidgetStateMouseCursor.clickable,
//                 child: GestureDetector(
//                   onTap: () async {
//                     setState(() {
//                       settings.defaultTheme = themeCollection[i];
//                     });
//                     theme.changeTheme(themeItem);
//                     await settings.saveSettings();
//                   },
//                   child: Stack(
//                     alignment: Alignment.center,
//                     children: [
//                       Container(
//                         width: 64.0,
//                         height: 64.0,
//                         decoration: BoxDecoration(
//                           color: themeItem.primary,
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         child: i == themeCollection.length - 1
//                             ? Align(
//                                 alignment: Alignment.bottomCenter,
//                                 child: Text(
//                                   "当前主题",
//                                   style: TextStyle(color: themeItem.onPrimary),
//                                 ),
//                               )
//                             : const SizedBox(),
//                       ),
//                       settings.defaultTheme == themeCollection[i]
//                           ? Icon(Symbols.check, color: themeItem.onPrimary)
//                           : const SizedBox(),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//         )
//       ],
//     );
//   }
// }

class ThemeModeControl extends StatefulWidget {
  const ThemeModeControl({super.key});

  @override
  State<ThemeModeControl> createState() => _ThemeModeControlState();
}

class _ThemeModeControlState extends State<ThemeModeControl> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "主题模式",
          style: TextStyle(color: scheme.onSurface, fontSize: 18.0),
        ),
        SegmentedButton<ThemeMode>(
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
          onSelectionChanged: (newSelection) {
            if (newSelection.first == settings.themeMode) return;

            setState(() {
              settings.themeMode = newSelection.first;
            });
            ThemeProvider.instance.applyThemeMode(settings.themeMode);
            settings.saveSettings();
          },
        ),
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
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "动态主题",
          style: TextStyle(color: scheme.onSurface, fontSize: 18.0),
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

class UseSystemThemeSwitch extends StatefulWidget {
  const UseSystemThemeSwitch({super.key});

  @override
  State<UseSystemThemeSwitch> createState() => _UseSystemThemeSwitchState();
}

class _UseSystemThemeSwitchState extends State<UseSystemThemeSwitch> {
  final settings = AppSettings.instance;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "启动时使用系统主题",
          style: TextStyle(color: scheme.onSurface, fontSize: 18.0),
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
    final scheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "启动时使用系统主题模式",
          style: TextStyle(color: scheme.onSurface, fontSize: 18.0),
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
