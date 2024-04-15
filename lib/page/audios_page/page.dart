import 'package:coriander_player/component/audio_tile.dart';
import 'page_controller.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class AudiosPage extends StatelessWidget {
  const AudiosPage({super.key, this.target});

  /// 指定歌曲列表的初始位置，着重显示该项
  final int? target;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AudiosPageController(),
      builder: (context, child) {
        final pageController = Provider.of<AudiosPageController>(context);

        final audiosSliverList = SliverList.builder(
          addAutomaticKeepAlives: false,
          itemCount: pageController.list.length,
          itemBuilder: (context, i) => AudioTile(
            audioIndex: i,
            playlist: pageController.list,
            focus: i == target,
          ),
        );

        final scrollController = ScrollController(
          initialScrollOffset: (target ?? 0) * 64,
        );

        return PageScaffold(
          title: "音乐",
          subtitle: "${pageController.list.length} 首乐曲",
          actions: const [
            _ShuffleAndPlay(),
            _SortMethodComboBox(),
            _ToggleListOrder(),
          ],
          body: Material(
            type: MaterialType.transparency,
            child: CustomScrollView(
              controller: scrollController,
              slivers: [
                audiosSliverList,
                const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
              ],
            ),
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
    final pageController = Provider.of<AudiosPageController>(context);
    final theme = Provider.of<ThemeProvider>(context);
    return FilledButton.icon(
      onPressed: () {
        PlayService.instance.shuffleAndPlay(pageController.list);
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
    final pageController = Provider.of<AudiosPageController>(context);

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
          leadingIcon: Icon(
            Symbols.title,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("标题"),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: Icon(
            Symbols.artist,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("艺术家"),
          onPressed: () => pageController.setSortMethod(SortBy.artist),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: Icon(
            Symbols.album,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("专辑"),
          onPressed: () => pageController.setSortMethod(SortBy.album),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: Icon(
            Symbols.add,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("创建时间"),
          onPressed: () => pageController.setSortMethod(SortBy.created),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: Icon(
            Symbols.edit,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("修改时间"),
          onPressed: () => pageController.setSortMethod(SortBy.modified),
        ),
        MenuItemButton(
          style: menuItemStyle,
          leadingIcon: Icon(
            Symbols.filter_list_off,
            color: theme.palette.onSecondaryContainer,
          ),
          child: const Text("默认"),
          onPressed: () => pageController.setSortMethod(SortBy.origin),
        ),
      ],
      builder: (context, menuController, _) {
        final theme = Provider.of<ThemeProvider>(context);
        final pageController = Provider.of<AudiosPageController>(context);

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
    final pageController = Provider.of<AudiosPageController>(context);

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
