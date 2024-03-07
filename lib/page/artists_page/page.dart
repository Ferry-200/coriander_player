import 'package:coriander_player/component/artist_tile.dart';
import 'package:coriander_player/page/artists_page/page_controller.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class ArtistsPage extends StatelessWidget {
  const ArtistsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistsPageController(),
      builder: (context, _) {
        final pageController = Provider.of<ArtistsPageController>(context);
        return PageScaffold(
          title: "艺术家",
          actions: const [_ToggleListOrder(), _SortMethodComboBox()],
          body: Material(
            type: MaterialType.transparency,
            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 96.0),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 300,
                mainAxisExtent: 64,
                mainAxisSpacing: 8.0,
                crossAxisSpacing: 8.0,
              ),
              itemCount: pageController.artistCollection.length,
              itemBuilder: (context, i) {
                final artist = pageController.artistCollection[i];
                return ArtistTile(artist: artist);
              },
            ),
          ),
        );
      },
    );
  }
}

class _SortMethodComboBox extends StatelessWidget {
  const _SortMethodComboBox();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final pageController = Provider.of<ArtistsPageController>(context);

    final menuItemStyle = ButtonStyle(
      backgroundColor: MaterialStatePropertyAll(
        theme.palette.secondaryContainer,
      ),
      foregroundColor: MaterialStatePropertyAll(
        theme.palette.onSecondaryContainer,
      ),
      padding: const MaterialStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 16.0),
      ),
      overlayColor: MaterialStatePropertyAll(
        theme.palette.onSecondaryContainer.withOpacity(0.08),
      ),
    );

    final menuStyle = MenuStyle(
      backgroundColor: MaterialStatePropertyAll(
        theme.palette.secondaryContainer,
      ),
      surfaceTintColor: MaterialStatePropertyAll(
        theme.palette.secondaryContainer,
      ),
      shape: const MaterialStatePropertyAll(RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
      )),
      fixedSize: const MaterialStatePropertyAll(Size.fromWidth(149.0)),
    );

    return MenuAnchor(
      /// 这样可以指定菜单栏的大小
      crossAxisUnconstrained: false,
      style: menuStyle,
      menuChildren: [
        MenuItemButton(
          style: menuItemStyle,
          onPressed: pageController.sortByName,
          leadingIcon: Icon(
            Symbols.title,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("名字"),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: Icon(
            Symbols.filter_list_off,
            color: theme.palette.onSecondaryContainer,
          ),
          onPressed: pageController.sortByOrigin,
          child: const Text("默认"),
        ),
      ],
      builder: (context, menuController, _) {
        final theme = Provider.of<ThemeProvider>(context);

        final isOpen = menuController.isOpen;

        final openBorderRadius = BorderRadius.circular(20.0);
        const closeBorderRadius = BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        );
        final borderRadius = isOpen ? closeBorderRadius : openBorderRadius;

        return SizedBox(
          height: 40.0,
          width: 149.0,
          child: Material(
            borderRadius: borderRadius,
            color: theme.palette.secondaryContainer,
            elevation: isOpen ? 4.0 : 0,
            child: InkWell(
              hoverColor: theme.palette.onSecondaryContainer.withOpacity(0.08),
              borderRadius: borderRadius,
              onTap: isOpen ? menuController.close : menuController.open,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                child: Row(
                  children: [
                    Icon(
                      Symbols.sort,
                      size: 24,
                      color: theme.palette.onSecondaryContainer,
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        pageController.sortMethod.methodName,
                        style: TextStyle(
                          color: theme.palette.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Icon(
                      isOpen ? Symbols.arrow_drop_up : Symbols.arrow_drop_down,
                      size: 24,
                      color: theme.palette.onSecondaryContainer,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ToggleListOrder extends StatelessWidget {
  const _ToggleListOrder();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final pageController = Provider.of<ArtistsPageController>(context);

    return IconButton(
      onPressed: pageController.toggleOrder,
      icon: Icon(
        pageController.order == ListOrder.ascending
            ? Symbols.arrow_upward
            : Symbols.arrow_downward,
      ),
      style: theme.secondaryIconButtonStyle,
    );
  }
}
