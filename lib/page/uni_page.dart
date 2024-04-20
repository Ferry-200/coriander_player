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

class UniPage<T> extends StatefulWidget {
  const UniPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.contentList,
    required this.contentBuilder,
    required this.enableShufflePlay,
    required this.enableSortBy,
    required this.enableSortOrder,
    required this.enableContentViewSwitch,
    required this.defaultContentView,
    this.sortMethods,
  });

  final String title;
  final String? subtitle;

  final List<T> contentList;
  final ContentBuilder<T> contentBuilder;

  final bool enableShufflePlay;
  final bool enableSortBy;
  final bool enableSortOrder;
  final bool enableContentViewSwitch;
  final ContentView defaultContentView;

  final List<SortMethodDesc<T>>? sortMethods;

  @override
  State<UniPage<T>> createState() => _UniPageState<T>();
}

class _UniPageState<T> extends State<UniPage<T>> {
  late List<T> contentList = widget.contentList;
  late SortMethodDesc<T>? currSortMethod = widget.sortMethods?.first;
  SortOrder sortOrder = SortOrder.ascending;
  late ContentView contentView = widget.defaultContentView;

  @override
  void initState() {
    super.initState();
    currSortMethod?.method(contentList, sortOrder);
  }

  void setSortMethod(SortMethodDesc<T> sortMethod) {
    setState(() {
      currSortMethod = sortMethod;
      this.currSortMethod?.method(contentList, sortOrder);
    });
  }

  void setSortOrder(SortOrder sortOrder) {
    setState(() {
      this.sortOrder = sortOrder;
      this.currSortMethod?.method(contentList, sortOrder);
    });
  }

  void setContentView(ContentView contentView) {
    setState(() {
      this.contentView = contentView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> actions = [];
    if (widget.enableShufflePlay) {
      actions.add(ShufflePlay<T>(contentList: contentList));
    }
    if (widget.enableSortBy) {
      actions.add(SortMethodComboBox<T>(
        sortMethods: widget.sortMethods!,
        contentList: contentList,
        currSortMethod: currSortMethod!,
        setSortMethod: setSortMethod,
      ));
    }
    if (widget.enableSortOrder) {
      actions.add(SortOrderSwitch<T>(
        sortOrder: sortOrder,
        setSortOrder: setSortOrder,
      ));
    }
    if (widget.enableContentViewSwitch) {
      actions.add(ContentViewSwitch<T>(
        contentView: contentView,
        setContentView: setContentView,
      ));
    }

    return PageScaffold(
      title: widget.title,
      subtitle: widget.subtitle,
      actions: actions,
      body: Material(
        type: MaterialType.transparency,
        child: switch (contentView) {
          ContentView.list => ListView.builder(
              padding: const EdgeInsets.only(bottom: 96.0),
              itemCount: contentList.length,
              itemBuilder: (context, i) => widget.contentBuilder(
                context,
                contentList[i],
                i,
              ),
            ),
          ContentView.table => GridView.builder(
              padding: const EdgeInsets.only(bottom: 96.0),
              gridDelegate: gridDelegate,
              itemCount: contentList.length,
              itemBuilder: (context, i) => widget.contentBuilder(
                context,
                contentList[i],
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
