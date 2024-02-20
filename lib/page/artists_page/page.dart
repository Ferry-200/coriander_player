import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

enum SortBy {
  name("名字"),
  origin("默认");

  final String methodName;
  const SortBy(this.methodName);
}

enum ListOrder { ascending, decending }

class ArtistsPage extends StatefulWidget {
  const ArtistsPage({super.key});

  @override
  State<ArtistsPage> createState() => _ArtistsPageState();
}

class _ArtistsPageState extends State<ArtistsPage> {
  List<Artist> artistCollection =
      AudioLibrary.instance.artistCollection.values.toList();

  ListOrder order = ListOrder.ascending;
  SortBy sortMethod = SortBy.origin;

  void _toggleOrder() {
    setState(() {
      artistCollection = artistCollection.reversed.toList();
      order = order == ListOrder.ascending
          ? ListOrder.decending
          : ListOrder.ascending;
    });
  }

  void _sortByName() {
    setState(() {
      switch (order) {
        case ListOrder.ascending:
          artistCollection.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ListOrder.decending:
          artistCollection.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
      sortMethod = SortBy.name;
    });
  }

  void _sortByOrigin() {
    setState(() {
      switch (order) {
        case ListOrder.ascending:
          artistCollection =
              AudioLibrary.instance.artistCollection.values.toList();
          break;
        case ListOrder.decending:
          artistCollection = AudioLibrary.instance.artistCollection.values
              .toList()
              .reversed
              .toList();
          break;
      }
      sortMethod = SortBy.origin;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return PageScaffold(
      title: "艺术家",
      actions: [
        _ToggleListOrder(order, _toggleOrder),
        _SortMethodComboBox(
          _sortByName,
          _sortByOrigin,
          sortMethod,
        )
      ],
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
          itemCount: artistCollection.length,
          itemBuilder: (BuildContext context, int i) {
            final artist = artistCollection[i];
            return InkWell(
              onTap: () => context.push(
                app_paths.ARTIST_DETAIL_PAGE,
                extra: artistCollection[i],
              ),
              borderRadius: BorderRadius.circular(8.0),
              hoverColor: theme.palette.onSurface.withOpacity(0.08),
              highlightColor: theme.palette.onSurface.withOpacity(0.12),
              splashColor: theme.palette.onSurface.withOpacity(0.12),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    FutureBuilder(
                      future: artist.works.first.cover,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Icon(
                            Symbols.broken_image,
                            color: theme.palette.onSurface,
                            size: 48,
                          );
                        }
                        return ClipOval(
                          child: Image(
                            image: snapshot.data!,
                            width: 48.0,
                            height: 48.0,
                          ),
                        );
                      },
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          artist.name,
                          style: TextStyle(
                            color: theme.palette.onSurface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SortMethodComboBox extends StatelessWidget {
  const _SortMethodComboBox(
      this._sortByName, this._sortByOrigin, this.sortMethod);

  final void Function() _sortByName;
  final void Function() _sortByOrigin;
  final SortBy sortMethod;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

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
          onPressed: _sortByName,
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
          onPressed: _sortByOrigin,
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
                        sortMethod.methodName,
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
  const _ToggleListOrder(this.order, this.onPressed);

  final ListOrder order;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        order == ListOrder.ascending
            ? Symbols.arrow_upward
            : Symbols.arrow_downward,
      ),
      style: theme.secondaryIconButtonStyle,
    );
  }
}
