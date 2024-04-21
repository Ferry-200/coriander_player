import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/page/settings_page/components.dart';
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
          AudioLibraryEditField(),
          SizedBox(height: 16.0),
          ThemeModeControl(),
          SizedBox(height: 16.0),
          DynamicThemeSwitch(),
          SizedBox(height: 16.0),
          ThemeSelector(),
          SizedBox(height: 16.0),
          CheckForUpdate(),
        ],
      ),
    );
  }
}