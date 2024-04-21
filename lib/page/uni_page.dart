import 'package:coriander_player/page/uni_page_components.dart';
import 'package:coriander_player/page/uni_page_controller.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';

typedef ContentBuilder<T> = Widget Function(
    BuildContext context, T item, int index);

const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 300,
  mainAxisExtent: 64,
  mainAxisSpacing: 8.0,
  crossAxisSpacing: 8.0,
);

/// `AudiosPage`, `ArtistsPage`, `AlbumsPage`, `FoldersPage`, `FolderDetailPage` 页面的主要组件，
/// 提供随机播放以及更改排序方式、排序顺序、内容视图的支持。
///
/// `enableShufflePlay` 只能在 `T` 是 `Audio` 时为 `ture`
///
/// `enableSortMethod` 为 `true` 时，`sortMethods` 不可为空且必须包含一个 `SortMethodDesc`
///
/// `defaultContentView` 表示默认的内容视图。如果设置为 `ContentView.list`，就以单行列表视图展示内容；
/// 如果是 `ContentView.table`，就以最大 300 * 64 的子组件以 8 为间距组成的表格展示内容。
class UniPage<T> extends StatefulWidget {
  const UniPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.contentList,
    required this.contentBuilder,
    required this.enableShufflePlay,
    required this.enableSortMethod,
    required this.enableSortOrder,
    required this.enableContentViewSwitch,
    required this.defaultContentView,
    this.sortMethods,
    this.locateTo,
  });

  final String title;
  final String? subtitle;

  final List<T> contentList;
  final ContentBuilder<T> contentBuilder;

  final bool enableShufflePlay;
  final bool enableSortMethod;
  final bool enableSortOrder;
  final bool enableContentViewSwitch;
  final ContentView defaultContentView;

  final List<SortMethodDesc<T>>? sortMethods;

  final T? locateTo;

  @override
  State<UniPage<T>> createState() => _UniPageState<T>();
}

class _UniPageState<T> extends State<UniPage<T>> {
  late List<T> currContentList = widget.contentList;
  late SortMethodDesc<T>? currSortMethod = widget.sortMethods?.first;
  SortOrder currSortOrder = SortOrder.ascending;
  late ContentView currContentView = widget.defaultContentView;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    currSortMethod?.method(currContentList, currSortOrder);
    int targetAt = 0;
    if (widget.locateTo != null) {
      targetAt = currContentList.indexOf(widget.locateTo as T);
    }
    scrollController = ScrollController(initialScrollOffset: targetAt * 64);
  }

  void setSortMethod(SortMethodDesc<T> sortMethod) {
    setState(() {
      currSortMethod = sortMethod;
      currSortMethod?.method(currContentList, currSortOrder);
    });
  }

  void setSortOrder(SortOrder sortOrder) {
    setState(() {
      currSortOrder = sortOrder;
      currSortMethod?.method(currContentList, currSortOrder);
    });
  }

  void setContentView(ContentView contentView) {
    setState(() {
      currContentView = contentView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];
    if (widget.enableShufflePlay) {
      actions.add(ShufflePlay<T>(contentList: currContentList));
    }
    if (widget.enableSortMethod) {
      actions.add(SortMethodComboBox<T>(
        sortMethods: widget.sortMethods!,
        contentList: currContentList,
        currSortMethod: currSortMethod!,
        setSortMethod: setSortMethod,
      ));
    }
    if (widget.enableSortOrder) {
      actions.add(SortOrderSwitch<T>(
        sortOrder: currSortOrder,
        setSortOrder: setSortOrder,
      ));
    }
    if (widget.enableContentViewSwitch) {
      actions.add(ContentViewSwitch<T>(
        contentView: currContentView,
        setContentView: setContentView,
      ));
    }

    return PageScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      actions: actions,
      body: Material(
        type: MaterialType.transparency,
        child: switch (currContentView) {
          ContentView.list => ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 96.0),
              itemCount: currContentList.length,
              itemBuilder: (context, i) => widget.contentBuilder(
                context,
                currContentList[i],
                i,
              ),
            ),
          ContentView.table => GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 96.0),
              gridDelegate: gridDelegate,
              itemCount: currContentList.length,
              itemBuilder: (context, i) => widget.contentBuilder(
                context,
                currContentList[i],
                i,
              ),
            ),
        },
      ),
    );
  }

  Expanded onlyTitle(ThemeProvider theme) => Expanded(
        child: Text(
          widget.title,
          style: TextStyle(fontSize: 32.0, color: theme.palette.onSurface),
          overflow: TextOverflow.ellipsis,
        ),
      );

  Expanded withSubtitle(ThemeProvider theme) => Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 28.0, color: theme.palette.onSurface),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              widget.subtitle!,
              style: TextStyle(fontSize: 14.0, color: theme.palette.onSurface),
              overflow: TextOverflow.ellipsis,
            )
          ],
        ),
      );
}
