// ignore_for_file: camel_case_types

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/horizontal_lyric_view.dart';
import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.small:
            return const _TitleBar_Small();
          case ScreenType.medium:
            return const _TitleBar_Medium();
          case ScreenType.large:
            return const _TitleBar_Large();
        }
      },
    );
  }
}

class _TitleBar_Small extends StatelessWidget {
  const _TitleBar_Small();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return SizedBox(
      height: 56.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const _OpenDrawerBtn(),
            const SizedBox(width: 8.0),
            const _NavBackBtn(),
            Expanded(
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Coriander Player",
                    style: TextStyle(
                      color: theme.scheme.onSurface,
                      fontSize: 16,
                    ),
                  ),
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

class _TitleBar_Medium extends StatelessWidget {
  const _TitleBar_Medium();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Center(child: _NavBackBtn()),
        ),
        Expanded(
          child: DragToMoveArea(
            child: Row(
              children: [
                Text(
                  "Coriander Player",
                  style: TextStyle(
                    color: theme.scheme.onSurface,
                    fontSize: 16,
                  ),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: HorizontalLyricView(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const WindowControlls(),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

class _TitleBar_Large extends StatelessWidget {
  const _TitleBar_Large();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const _NavBackBtn(),
          const SizedBox(width: 8.0),
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  SizedBox(
                    width: 228,
                    child: Row(
                      children: [
                        Image.asset(
                          "app_icon.ico",
                          width: 24,
                          height: 24,
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
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8.0, 16.0, 8.0),
                      child: HorizontalLyricView(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const WindowControlls(),
        ],
      ),
    );
  }
}

class _OpenDrawerBtn extends StatelessWidget {
  const _OpenDrawerBtn();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return IconButton(
      onPressed: () {
        Scaffold.of(context).openDrawer();
      },
      icon: Icon(
        Symbols.side_navigation,
        color: theme.scheme.onSurface,
      ),
      hoverColor: theme.scheme.onSurface.withOpacity(0.08),
      highlightColor: theme.scheme.onSurface.withOpacity(0.12),
      splashColor: theme.scheme.onSurface.withOpacity(0.12),
    );
  }
}

class _NavBackBtn extends StatelessWidget {
  const _NavBackBtn();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return IconButton(
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      icon: Icon(
        Symbols.navigate_before,
        color: theme.scheme.onSurface,
      ),
      hoverColor: theme.scheme.onSurface.withOpacity(0.08),
      highlightColor: theme.scheme.onSurface.withOpacity(0.12),
      splashColor: theme.scheme.onSurface.withOpacity(0.12),
    );
  }
}

class WindowControlls extends StatefulWidget {
  const WindowControlls({super.key});

  @override
  State<WindowControlls> createState() => _WindowControllsState();
}

class _WindowControllsState extends State<WindowControlls> with WindowListener {
  @override
  void initState() {
    windowManager.addListener(this);
    super.initState();
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  @override
  void onWindowRestore() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Wrap(
      spacing: 8.0,
      children: [
        IconButton(
          onPressed: windowManager.minimize,
          icon: Icon(
            Symbols.remove,
            color: theme.scheme.onSurface,
          ),
          hoverColor: theme.scheme.onSurface.withOpacity(0.08),
          highlightColor: theme.scheme.onSurface.withOpacity(0.12),
          splashColor: theme.scheme.onSurface.withOpacity(0.12),
        ),
        FutureBuilder(
          future: windowManager.isMaximized(),
          builder: (context, snapshot) {
            final isMaximized = snapshot.data ?? false;
            return IconButton(
              onPressed: isMaximized
                  ? windowManager.unmaximize
                  : windowManager.maximize,
              icon: Icon(
                isMaximized ? Symbols.fullscreen_exit : Symbols.fullscreen,
                color: theme.scheme.onSurface,
              ),
              hoverColor: theme.scheme.onSurface.withOpacity(0.08),
              highlightColor: theme.scheme.onSurface.withOpacity(0.12),
              splashColor: theme.scheme.onSurface.withOpacity(0.12),
            );
          },
        ),
        IconButton(
          onPressed: () async {
            await savePlaylists();
            await saveLyricSources();
            await AppSettings.instance.saveSettings();
            windowManager.close();
          },
          icon: Icon(
            Symbols.close,
            color: theme.scheme.onSurface,
          ),
          hoverColor: theme.scheme.onSurface.withOpacity(0.08),
          highlightColor: theme.scheme.onSurface.withOpacity(0.12),
          splashColor: theme.scheme.onSurface.withOpacity(0.12),
        ),
      ],
    );
  }
}
