import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class NowPlayingPageTitleBar extends StatelessWidget {
  const NowPlayingPageTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Column(
      children: [
        const SizedBox(
          height: 48.0,
          child: Row(
            children: [
              Expanded(child: DragToMoveArea(child: SizedBox.expand())),
              WindowControlls(),
            ],
          ),
        ),
        SizedBox(
          height: 32.0,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
              highlightColor:
                  theme.palette.onSecondaryContainer.withOpacity(0.12),
              splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
              onTap: () => context.pop(),
              child: Center(
                child: Icon(
                  Symbols.arrow_drop_down,
                  color: theme.palette.onSecondaryContainer,
                ),
              ),
            ),
          ),
        )
      ],
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
  Future<void> onWindowClose() async {
    super.onWindowClose();
    await savePlaylists();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: windowManager.minimize,
            icon: Icon(
              Symbols.remove,
              color: theme.palette.onSecondaryContainer,
            ),
            hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
            highlightColor:
                theme.palette.onSecondaryContainer.withOpacity(0.12),
            splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          ),
          const SizedBox(width: 8.0),
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
                  color: theme.palette.onSecondaryContainer,
                ),
                hoverColor:
                    theme.palette.onSecondaryContainer.withOpacity(0.08),
                highlightColor:
                    theme.palette.onSecondaryContainer.withOpacity(0.12),
                splashColor:
                    theme.palette.onSecondaryContainer.withOpacity(0.12),
              );
            },
          ),
          const SizedBox(width: 8.0),
          IconButton(
            onPressed: windowManager.close,
            icon: Icon(
              Symbols.close,
              color: theme.palette.onSecondaryContainer,
            ),
            hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
            highlightColor:
                theme.palette.onSecondaryContainer.withOpacity(0.12),
            splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
          ),
        ],
      ),
    );
  }
}
