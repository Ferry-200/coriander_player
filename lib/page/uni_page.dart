import 'package:coriander_player/page/uni_page_components.dart';
import 'package:coriander_player/page/page_scaffold.dart';
import 'package:flutter/material.dart';

typedef ContentBuilder<T> = Widget Function(BuildContext context, T item,
    int index, MultiSelectController<T>? multiSelectController);

typedef SortMethod<T> = void Function(List<T> list, SortOrder order);

class SortMethodDesc<T> {
  IconData icon;
  String name;
  SortMethod<T> method;

  SortMethodDesc({
    required this.icon,
    required this.name,
    required this.method,
  });
}

enum SortOrder { ascending, decending }

enum ContentView { list, table }

const gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
  maxCrossAxisExtent: 300,
  mainAxisExtent: 64,
  mainAxisSpacing: 8.0,
  crossAxisSpacing: 8.0,
);

class MultiSelectController<T> extends ChangeNotifier {
  final Set<T> selected = {};
  bool enableMultiSelectView = false;

  void useMultiSelectView(bool multiSelectView) {
    enableMultiSelectView = multiSelectView;
    notifyListeners();
  }

  void select(T item) {
    selected.add(item);
    notifyListeners();
  }

  void unselect(T item) {
    selected.remove(item);
    notifyListeners();
  }

  void clear() {
    selected.clear();
    notifyListeners();
  }

  void selectAll(Iterable<T> items) {
    selected.addAll(items);
    notifyListeners();
  }
}

/// `AudiosPage`, `ArtistsPage`, `AlbumsPage`, `FoldersPage`, `FolderDetailPage` 页面的主要组件，
/// 提供随机播放以及更改排序方式、排序顺序、内容视图的支持。
///
/// `enableShufflePlay` 只能在 `T` 是 `Audio` 时为 `ture`
///
/// `enableSortMethod` 为 `true` 时，`sortMethods` 不可为空且必须包含一个 `SortMethodDesc`
///
/// `defaultContentView` 表示默认的内容视图。如果设置为 `ContentView.list`，就以单行列表视图展示内容；
/// 如果是 `ContentView.table`，就以最大 300 * 64 的子组件以 8 为间距组成的表格展示内容。
/// 
/// `multiSelectController` 可以使页面进入多选状态。如果它不为空，则 `multiSelectViewActions` 也不可为空
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
    this.multiSelectController,
    this.multiSelectViewActions,
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

  final MultiSelectController<T>? multiSelectController;
  final List<Widget>? multiSelectViewActions;

  @override
  State<UniPage<T>> createState() => _UniPageState<T>();
}

class _UniPageState<T> extends State<UniPage<T>> {
  late SortMethodDesc<T>? currSortMethod = widget.sortMethods?.first;
  SortOrder currSortOrder = SortOrder.ascending;
  late ContentView currContentView = widget.defaultContentView;
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    currSortMethod?.method(widget.contentList, currSortOrder);
    int targetAt = 0;
    if (widget.locateTo != null) {
      targetAt = widget.contentList.indexOf(widget.locateTo as T);
    }
    scrollController = ScrollController(initialScrollOffset: targetAt * 64);
  }

  @override
  void didUpdateWidget(covariant UniPage<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    currSortMethod?.method(widget.contentList, currSortOrder);
  }

  void setSortMethod(SortMethodDesc<T> sortMethod) {
    setState(() {
      currSortMethod = sortMethod;
      currSortMethod?.method(widget.contentList, currSortOrder);
    });
  }

  void setSortOrder(SortOrder sortOrder) {
    setState(() {
      currSortOrder = sortOrder;
      currSortMethod?.method(widget.contentList, currSortOrder);
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
      actions.add(ShufflePlay<T>(contentList: widget.contentList));
    }
    if (widget.enableSortMethod) {
      actions.add(SortMethodComboBox<T>(
        sortMethods: widget.sortMethods!,
        contentList: widget.contentList,
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

    return widget.multiSelectController == null
        ? result(null, actions)
        : ListenableBuilder(
            listenable: widget.multiSelectController!,
            builder: (context, _) => result(
              widget.multiSelectController!,
              actions,
            ),
          );
  }

  Widget result(
      MultiSelectController<T>? multiSelectController, List<Widget> actions) {
    return PageScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      actions: multiSelectController == null
          ? actions
          : multiSelectController.enableMultiSelectView
              ? widget.multiSelectViewActions!
              : actions,
      body: Material(
        type: MaterialType.transparency,
        child: switch (currContentView) {
          ContentView.list => ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 96.0),
              itemCount: widget.contentList.length,
              itemBuilder: (context, i) => widget.contentBuilder(
                context,
                widget.contentList[i],
                i,
                multiSelectController,
              ),
            ),
          ContentView.table => GridView.builder(
              controller: scrollController,
              padding: const EdgeInsets.only(bottom: 96.0),
              gridDelegate: gridDelegate,
              itemCount: widget.contentList.length,
              itemBuilder: (context, i) => widget.contentBuilder(
                context,
                widget.contentList[i],
                i,
                multiSelectController,
              ),
            ),
        },
      ),
    );
  }
}
