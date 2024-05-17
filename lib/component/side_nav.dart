// ignore_for_file: camel_case_types

import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';

class DestinationDesc {
  final IconData icon;
  final String label;
  final String desPath;
  DestinationDesc(this.icon, this.label, this.desPath);
}

class SideNav extends StatefulWidget {
  const SideNav({super.key});

  @override
  State<SideNav> createState() => _SideNavState();
}

class _SideNavState extends State<SideNav> {
  final destinations = <DestinationDesc>[
    DestinationDesc(Symbols.library_music, "音乐", app_paths.AUDIOS_PAGE),
    DestinationDesc(Symbols.artist, "艺术家", app_paths.ARTISTS_PAGE),
    DestinationDesc(Symbols.album, "专辑", app_paths.ALBUMS_PAGE),
    DestinationDesc(Symbols.folder, "文件夹", app_paths.FOLDERS_PAGE),
    DestinationDesc(Symbols.list, "歌单", app_paths.PLAYLISTS_PAGE),
    DestinationDesc(Symbols.search, "搜索", app_paths.SEARCH_PAGE),
    DestinationDesc(Symbols.settings, "设置", app_paths.SETTINGS_PAGE),
  ];

  int selected = 0;

  void onDestinationSelected(int value) {
    if (value == selected) return;
    context.push(destinations[value].desPath);
    setState(() {
      selected = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.small:
          case ScreenType.large:
            return NavigationDrawer(
              selectedIndex: selected,
              onDestinationSelected: onDestinationSelected,
              children: List.generate(
                destinations.length,
                (i) => NavigationDrawerDestination(
                  icon: Icon(destinations[i].icon),
                  label: Text(destinations[i].label),
                ),
              ),
            );
          case ScreenType.medium:
            return NavigationRail(
              selectedIndex: selected,
              onDestinationSelected: onDestinationSelected,
              destinations: List.generate(
                destinations.length,
                (i) => NavigationRailDestination(
                  icon: Icon(destinations[i].icon),
                  label: Text(destinations[i].label),
                ),
              ),
            );
        }
      },

      // return DecoratedBox(
      //   decoration: BoxDecoration(
      //     color: theme.scheme.surfaceContainer,
      //     borderRadius: const BorderRadius.horizontal(
      //       right: Radius.circular(12.0),
      //     ),
      //   ),
      //   child: SizedBox(
      //     width: screenType == ScreenType.medium ? 80.0 : 284.0,
      //     child: Padding(
      //       padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 8.0),
      //       child: Column(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Column(
      //             children: [
      //               SideNavItem(
      //                 isSelected: selected == 0,
      //                 onTap: () {
      //                   if (selected != 0) {
      //                     context.push(app_paths.AUDIOS_PAGE);
      //                   }
      //                 },
      //                 icon: Symbols.library_music,
      //                 label: "音乐",
      //               ),
      //               SideNavItem(
      //                 isSelected: selected == 1,
      //                 onTap: () {
      //                   if (selected != 1) {
      //                     context.push(app_paths.ARTISTS_PAGE);
      //                   }
      //                 },
      //                 icon: Symbols.artist,
      //                 label: "艺术家",
      //               ),
      //               SideNavItem(
      //                 isSelected: selected == 2,
      //                 onTap: () {
      //                   if (selected != 2) {
      //                     context.push(app_paths.ALBUMS_PAGE);
      //                   }
      //                 },
      //                 icon: Symbols.album,
      //                 label: "专辑",
      //               ),
      //               SideNavItem(
      //                 isSelected: selected == 3,
      //                 onTap: () {
      //                   if (selected != 3) {
      //                     context.push(app_paths.FOLDERS_PAGE);
      //                   }
      //                 },
      //                 icon: Symbols.folder,
      //                 label: "文件夹",
      //               ),
      //               SideNavItem(
      //                 isSelected: selected == 4,
      //                 onTap: () {
      //                   if (selected != 4) {
      //                     context.push(app_paths.PLAYLISTS_PAGE);
      //                   }
      //                 },
      //                 icon: Symbols.list,
      //                 label: "歌单",
      //               ),
      //               SideNavItem(
      //                 isSelected: selected == 5,
      //                 onTap: () {
      //                   if (selected != 5) {
      //                     context.push(app_paths.SEARCH_PAGE);
      //                   }
      //                 },
      //                 icon: Symbols.search,
      //                 label: "搜索",
      //               ),
      //             ],
      //           ),
      //           SideNavItem(
      //             isSelected: selected == 6,
      //             onTap: () {
      //               if (selected != 6) {
      //                 context.push(app_paths.SETTINGS_PAGE);
      //               }
      //             },
      //             icon: Symbols.settings,
      //             label: "设置",
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // );
    );
  }
}
