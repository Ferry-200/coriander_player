import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/playlist.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';

class NowPlayingPageTitleBar extends StatefulWidget {
  const NowPlayingPageTitleBar({super.key});

  @override
  State<NowPlayingPageTitleBar> createState() => _NowPlayingPageTitleBarState();
}

class _NowPlayingPageTitleBarState extends State<NowPlayingPageTitleBar>
    with WindowListener {
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
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return ResponsiveBuilder(builder: (context, screenType) {
      return DragToMoveArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// back to main page
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                width: screenType == ScreenType.small ? 100.0 : 300,
                height: 32.0,
                child: Material(
                  type: MaterialType.transparency,
                  borderRadius: BorderRadius.circular(16.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    hoverColor:
                        theme.palette.onSecondaryContainer.withOpacity(0.08),
                    highlightColor:
                        theme.palette.onSecondaryContainer.withOpacity(0.12),
                    splashColor:
                        theme.palette.onSecondaryContainer.withOpacity(0.12),
                    onTap: () => context.pop(),
                    child: Center(
                      child: Icon(
                        Symbols.arrow_drop_down,
                        color: theme.palette.onSecondaryContainer,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            /// window controls
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: windowManager.minimize,
                      icon: Icon(
                        Symbols.remove,
                        color: theme.palette.onSurface,
                      ),
                      hoverColor: theme.palette.onSurface.withOpacity(0.08),
                      highlightColor: theme.palette.onSurface.withOpacity(0.12),
                      splashColor: theme.palette.onSurface.withOpacity(0.12),
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
                            isMaximized
                                ? Symbols.fullscreen_exit
                                : Symbols.fullscreen,
                            color: theme.palette.onSurface,
                          ),
                          hoverColor: theme.palette.onSurface.withOpacity(0.08),
                          highlightColor:
                              theme.palette.onSurface.withOpacity(0.12),
                          splashColor:
                              theme.palette.onSurface.withOpacity(0.12),
                        );
                      },
                    ),
                    const SizedBox(width: 8.0),
                    IconButton(
                      onPressed: () async {
                        await savePlaylists();
                        windowManager.close();
                      },
                      icon: Icon(
                        Symbols.close,
                        color: theme.palette.onSurface,
                      ),
                      hoverColor: theme.palette.onSurface.withOpacity(0.08),
                      highlightColor: theme.palette.onSurface.withOpacity(0.12),
                      splashColor: theme.palette.onSurface.withOpacity(0.12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
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
  void onWindowClose() {
    super.onWindowClose();
    savePlaylists();
  }
}
