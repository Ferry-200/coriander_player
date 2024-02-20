import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/component/audio_tile.dart';
import 'package:coriander_player/page/artist_detail_page/page_controller.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

/// 两种方式：artists_page -> album_detail_page
///          artist_detail_page
/// 当artists_page把该page当成组件使用时，必须传controller。
/// 否则会出现选择的艺术家是这个但页面内容是另一个的问题
class ArtistDetailPage extends StatelessWidget {
  const ArtistDetailPage({
    super.key,
    required this.artist,
  });

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistDetailPageController(artist),
      builder: _pageBuilder,
      child: _ArtistPicture(artist: artist),
    );
  }

  Widget _pageBuilder(context, albumCover) {
    final theme = Provider.of<ThemeProvider>(context);
    final pageController = Provider.of<ArtistDetailPageController>(context);

    return Material(
      color: theme.palette.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            /// pic, name of artist and actions
            SliverToBoxAdapter(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  albumCover!,
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: Text(
                            artist.name,
                            style: TextStyle(
                              fontSize: 22.0,
                              color: theme.palette.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        const Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: [
                            _ShuffleAndPlay(),
                            _SortMethodComboBox(),
                            _ToggleListOrder(),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Divider(
                height: 32.0,
                color: theme.palette.outline,
                indent: 8.0,
                endIndent: 8.0,
              ),
            ),

            /// list of artist works
            SliverList.builder(
              itemCount: pageController.works.length,
              itemBuilder: (context, i) => AudioTile(
                audioIndex: i,
                playlist: pageController.works,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "专辑",
                  style: TextStyle(
                    color: theme.palette.onSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const _AlbumsSliverList(),
            const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
          ],
        ),
      ),
    );
  }
}

class _AlbumsSliverList extends StatelessWidget {
  const _AlbumsSliverList();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final pageController = Provider.of<ArtistDetailPageController>(context);

    return SliverList.builder(
      itemCount: pageController.albums.length,
      itemBuilder: (context, i) {
        final album = pageController.albums[i];
        return ListTile(
          onTap: () => context.push(app_paths.ALBUM_DETAIL_PAGE, extra: album),
          title: Text(album.name),
          textColor: theme.palette.onSurface,
          hoverColor: theme.palette.onSurface.withOpacity(0.08),
          splashColor: theme.palette.onSurface.withOpacity(0.12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        );
      },
    );
  }
}

class _ArtistPicture extends StatelessWidget {
  const _ArtistPicture({
    required this.artist,
  });

  final Artist artist;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: artist.picture,
      builder: (context, snapshot) {
        final theme = Provider.of<ThemeProvider>(context);
        if (snapshot.data == null) {
          return Flexible(
            child: Icon(
              Symbols.broken_image,
              size: 200.0,
              color: theme.palette.onSurface,
            ),
          );
        }
        return ClipOval(
          child: Image(
            image: snapshot.data!,
            width: 200.0,
            height: 200.0,
          ),
        );
      },
    );
  }
}

class _ShuffleAndPlay extends StatelessWidget {
  const _ShuffleAndPlay();

  @override
  Widget build(BuildContext context) {
    final pageController = Provider.of<ArtistDetailPageController>(context);
    final theme = Provider.of<ThemeProvider>(context);
    return FilledButton.icon(
      onPressed: () {
        PlayService.instance.shuffleAndPlay(pageController.works);
      },
      icon: const Icon(Symbols.shuffle),
      label: const Text("随机播放"),
      style: theme.primaryButtonStyle,
    );
  }
}

class _SortMethodComboBox extends StatelessWidget {
  const _SortMethodComboBox();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final pageController = Provider.of<ArtistDetailPageController>(context);

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
          onPressed: () => pageController.setSortMethod(SortBy.title),
          leadingIcon: const Icon(Symbols.title),
          child: const Text("标题"),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: const Icon(Symbols.album),
          child: const Text("专辑"),
          onPressed: () => pageController.setSortMethod(SortBy.album),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: const Icon(Symbols.add),
          child: const Text("创建时间"),
          onPressed: () => pageController.setSortMethod(SortBy.created),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: const Icon(Symbols.edit),
          child: const Text("修改时间"),
          onPressed: () => pageController.setSortMethod(SortBy.modified),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: const Icon(Symbols.filter_list_off),
          child: const Text("默认"),
          onPressed: () => pageController.setSortMethod(SortBy.origin),
        ),
      ],
      builder: (context, menuController, _) {
        final theme = Provider.of<ThemeProvider>(context);
        final pageController = Provider.of<ArtistDetailPageController>(context);

        final sortMethod = pageController.sortBy;
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
              highlightColor:
                  theme.palette.onSecondaryContainer.withOpacity(0.12),
              splashColor: theme.palette.onSecondaryContainer.withOpacity(0.12),
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
  const _ToggleListOrder();

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final pageController = Provider.of<ArtistDetailPageController>(context);

    return IconButton(
      onPressed: () {
        pageController.setListOrder(
          pageController.listOrder == ListOrder.ascending
              ? ListOrder.decending
              : ListOrder.ascending,
        );
      },
      icon: Icon(
        pageController.listOrder == ListOrder.ascending
            ? Symbols.arrow_upward
            : Symbols.arrow_downward,
      ),
      style: theme.secondaryIconButtonStyle,
    );
  }
}
