import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

enum SortBy {
  name("标题"),
  artist("艺术家"),
  origin("默认");

  final String methodName;
  const SortBy(this.methodName);
}

enum ListOrder { ascending, decending }

class AlbumsPage extends StatefulWidget {
  const AlbumsPage({super.key});

  @override
  State<AlbumsPage> createState() => _AlbumsPageState();
}

class _AlbumsPageState extends State<AlbumsPage> {
  List<Album> albumCollection =
      AudioLibrary.instance.albumCollection.values.toList();

  ListOrder order = ListOrder.ascending;
  SortBy sortMethod = SortBy.origin;

  void _toggleOrder() {
    setState(() {
      albumCollection = albumCollection.reversed.toList();
      order = order == ListOrder.ascending
          ? ListOrder.decending
          : ListOrder.ascending;
    });
  }

  void _sortByName() {
    setState(() {
      switch (order) {
        case ListOrder.ascending:
          albumCollection.sort((a, b) => a.name.compareTo(b.name));
          break;
        case ListOrder.decending:
          albumCollection.sort((a, b) => b.name.compareTo(a.name));
          break;
      }
      sortMethod = SortBy.name;
    });
  }

  void _sortByArtist() {
    setState(() {
      switch (order) {
        case ListOrder.ascending:
          albumCollection.sort(
            (a, b) => a.artistsMap.values.first.name.compareTo(
              b.artistsMap.values.first.name,
            ),
          );
          break;
        case ListOrder.decending:
          albumCollection.sort(
            (a, b) => b.artistsMap.values.first.name.compareTo(
              a.artistsMap.values.first.name,
            ),
          );
          break;
      }
      sortMethod = SortBy.artist;
    });
  }

  void _sortByOrigin() {
    setState(() {
      switch (order) {
        case ListOrder.ascending:
          albumCollection =
              AudioLibrary.instance.albumCollection.values.toList();
          break;
        case ListOrder.decending:
          albumCollection = AudioLibrary.instance.albumCollection.values
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
      title: "专辑",
      actions: [
        _ToggleListOrder(order, _toggleOrder),
        _SortMethodComboBox(
          _sortByName,
          _sortByArtist,
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
          itemCount: albumCollection.length,
          itemBuilder: (BuildContext context, int i) {
            final album = albumCollection[i];
            return InkWell(
              onTap: () => context.push(
                app_paths.ALBUM_DETAIL_PAGE,
                extra: albumCollection[i],
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
                      future: album.works.first.cover,
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return Icon(
                            Symbols.broken_image,
                            color: theme.palette.onSurface,
                            size: 48,
                          );
                        }
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
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
                          album.name,
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
  const _SortMethodComboBox(this._sortByName, this._sortByArtist,
      this._sortByOrigin, this.sortMethod);

  final void Function() _sortByName;
  final void Function() _sortByArtist;
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
          leadingIcon: const Icon(Symbols.title),
          child: const Text("标题"),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: const Icon(Symbols.artist),
          onPressed:  _sortByArtist,
          child: const Text("艺术家"),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: const Icon(Symbols.filter_list_off),
          onPressed:  _sortByOrigin,
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
