import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class _SideNavItem_Medium extends StatelessWidget {
  const _SideNavItem_Medium(
      {super.key,
      required this.isSelected,
      required this.onTap,
      required this.icon,
      required this.label});

  final bool isSelected;
  final void Function() onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final scaffold = Scaffold.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        children: [
          Material(
            color: isSelected
                ? theme.palette.secondaryContainer
                : theme.palette.surfaceContainer,
            borderRadius: BorderRadius.circular(24.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(24.0),
              onTap: () {
                onTap();
                if (scaffold.hasDrawer) {
                  scaffold.closeDrawer();
                }
              },
              hoverColor: (isSelected
                      ? theme.palette.onSecondaryContainer
                      : theme.palette.onSurface)
                  .withOpacity(0.08),
              highlightColor: (isSelected
                      ? theme.palette.onSecondaryContainer
                      : theme.palette.onSurface)
                  .withOpacity(0.12),
              splashColor: (isSelected
                      ? theme.palette.onSecondaryContainer
                      : theme.palette.onSurface)
                  .withOpacity(0.12),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Icon(
                    icon,
                    size: 24,
                    color: isSelected
                        ? theme.palette.onSecondaryContainer
                        : theme.palette.onSurface,
                  ),
                ),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.palette.onSurface,
            ),
          )
        ],
      ),
    );
  }
}

class _SideNavItem_Large extends StatelessWidget {
  const _SideNavItem_Large(
      {super.key,
      required this.isSelected,
      required this.onTap,
      required this.icon,
      required this.label});

  final bool isSelected;
  final void Function() onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final scaffold = Scaffold.of(context);

    return SizedBox(
      height: 48.0,
      child: Material(
        color: isSelected
            ? theme.palette.secondaryContainer
            : theme.palette.surfaceContainer,
        borderRadius: BorderRadius.circular(24.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(24.0),
          onTap: () {
            onTap();
            if (scaffold.hasDrawer) {
              scaffold.closeDrawer();
            }
          },
          hoverColor: (isSelected
                  ? theme.palette.onSecondaryContainer
                  : theme.palette.onSurface)
              .withOpacity(0.08),
          highlightColor: (isSelected
                  ? theme.palette.onSecondaryContainer
                  : theme.palette.onSurface)
              .withOpacity(0.12),
          splashColor: (isSelected
                  ? theme.palette.onSecondaryContainer
                  : theme.palette.onSurface)
              .withOpacity(0.12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? theme.palette.onSecondaryContainer
                      : theme.palette.onSurface,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? theme.palette.onSecondaryContainer
                          : theme.palette.onSurface,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SideNavItem extends StatelessWidget {
  const SideNavItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.icon,
    required this.label,
  });

  final bool isSelected;
  final void Function() onTap;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.medium:
            return _SideNavItem_Medium(
              isSelected: isSelected,
              onTap: onTap,
              icon: icon,
              label: label,
            );
          case ScreenType.small:
          case ScreenType.large:
            return _SideNavItem_Large(
              isSelected: isSelected,
              onTap: onTap,
              icon: icon,
              label: label,
            );
        }
      },
    );
  }
}

class SideNav extends StatelessWidget {
  const SideNav({super.key});

  /// 获取当前页面，更新选择的页面
  int judgeSelected(BuildContext context) {
    final uri = GoRouterState.of(context).uri.toString();
    if (uri.startsWith(app_paths.AUDIOS_PAGE)) {
      return 0;
    } else if (uri.startsWith(app_paths.ARTISTS_PAGE)) {
      return 1;
    } else if (uri.startsWith(app_paths.ALBUMS_PAGE)) {
      return 2;
    } else if (uri.startsWith(app_paths.FOLDERS_PAGE)) {
      return 3;
    } else if (uri.startsWith(app_paths.PLAYLISTS_PAGE)) {
      return 4;
    } else if (uri.startsWith(app_paths.SEARCH_PAGE)) {
      return 5;
    } else if (uri.startsWith(app_paths.SETTINGS_PAGE)) {
      return 6;
    }
    return -1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    int selected = judgeSelected(context);
    return ResponsiveBuilder(builder: (context, screenType) {
      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.palette.surfaceContainer,
          borderRadius: const BorderRadius.horizontal(
            right: Radius.circular(12.0),
          ),
        ),
        child: SizedBox(
          width: screenType == ScreenType.medium ? 80.0 : 284.0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SideNavItem(
                      isSelected: selected == 0,
                      onTap: () {
                        if (selected != 0) {
                          context.push(app_paths.AUDIOS_PAGE);
                        }
                      },
                      icon: Symbols.library_music,
                      label: "音乐",
                    ),
                    SideNavItem(
                      isSelected: selected == 1,
                      onTap: () {
                        if (selected != 1) {
                          context.push(app_paths.ARTISTS_PAGE);
                        }
                      },
                      icon: Symbols.artist,
                      label: "艺术家",
                    ),
                    SideNavItem(
                      isSelected: selected == 2,
                      onTap: () {
                        if (selected != 2) {
                          context.push(app_paths.ALBUMS_PAGE);
                        }
                      },
                      icon: Symbols.album,
                      label: "专辑",
                    ),
                    SideNavItem(
                      isSelected: selected == 3,
                      onTap: () {
                        if (selected != 3) {
                          context.push(app_paths.FOLDERS_PAGE);
                        }
                      },
                      icon: Symbols.folder,
                      label: "文件夹",
                    ),
                    SideNavItem(
                      isSelected: selected == 4,
                      onTap: () {
                        if (selected != 4) {
                          context.push(app_paths.PLAYLISTS_PAGE);
                        }
                      },
                      icon: Symbols.list,
                      label: "歌单",
                    ),
                    SideNavItem(
                      isSelected: selected == 5,
                      onTap: () {
                        if (selected != 5) {
                          context.push(app_paths.SEARCH_PAGE);
                        }
                      },
                      icon: Symbols.search,
                      label: "搜索",
                    ),
                  ],
                ),
                SideNavItem(
                  isSelected: selected == 6,
                  onTap: () {
                    if (selected != 6) {
                      context.push(app_paths.SETTINGS_PAGE);
                    }
                  },
                  icon: Symbols.settings,
                  label: "设置",
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
