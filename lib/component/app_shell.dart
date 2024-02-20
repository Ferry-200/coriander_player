// ignore_for_file: camel_case_types

import 'package:coriander_player/component/mini_now_playing.dart';
import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/component/side_nav.dart';
import 'package:coriander_player/component/title_bar.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.small:
            return _AppShell_Small(page: page);
          case ScreenType.medium:
          case ScreenType.large:
            return _AppShell_Large(page: page);
        }
      },
    );
  }
}

class _AppShell_Small extends StatelessWidget {
  const _AppShell_Small({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.palette.surfaceContainer,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: TitleBar(),
      ),
      drawer: const SideNav(),
      body: Stack(children: [page, const MiniNowPlaying()]),
    );
  }
}

class _AppShell_Large extends StatelessWidget {
  const _AppShell_Large({super.key, required this.page});

  final Widget page;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Scaffold(
      backgroundColor: theme.palette.surfaceContainer,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: TitleBar(),
      ),
      body: Row(
        children: [
          const SideNav(),
          Expanded(
            child: Stack(children: [page, const MiniNowPlaying()]),
          ),
        ],
      ),
    );
  }
}
