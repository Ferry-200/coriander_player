import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/page/settings_page/artist_separator_editor.dart';
import 'package:coriander_player/page/settings_page/check_update.dart';
import 'package:coriander_player/page/settings_page/create_issue.dart';
import 'package:coriander_player/page/settings_page/other_settings.dart';
import 'package:coriander_player/page/settings_page/theme_settings.dart';
import 'package:flutter/material.dart';

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
          AudioLibraryEditor(),
          SizedBox(height: 16.0),
          DefaultLyricSourceControl(),
          SizedBox(height: 16.0),
          DynamicThemeSwitch(),
          SizedBox(height: 16.0),
          UseSystemThemeSwitch(),
          SizedBox(height: 16.0),
          ThemeSelector(),
          SizedBox(height: 16.0),
          UseSystemThemeModeSwitch(),
          SizedBox(height: 16.0),
          ThemeModeControl(),
          SizedBox(height: 16.0),
          SelectFontCombobox(),
          SizedBox(height: 16.0),
          ArtistSeparatorEditor(),
          SizedBox(height: 16.0),
          CreateIssueTile(),
          SizedBox(height: 16.0),
          CheckForUpdate(),
        ],
      ),
    );
  }
}
