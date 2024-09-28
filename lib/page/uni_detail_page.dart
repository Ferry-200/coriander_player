import 'dart:ui';

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:coriander_player/page/uni_page_components.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// `ArtistDetailPage`, `AlbumDetailPage` 页面的主要组件。
///
/// `P`: 第一内容；`S`: 第二内容（主要）；`T`: 第三内容
///
/// 例如：对于 `ArtistDetailPage` 来说，
/// `P` 是 `Artist` 类，`S` 是 `Audio` 类，`T` 是 `Album` 类
///
/// `multiSelectController` 可以使页面进入多选状态。如果它不为空，则 `multiSelectViewActions` 也不可为空
class UniDetailPage<P, S, T> extends StatefulWidget {
  const UniDetailPage({
    super.key,
    required this.pref,
    required this.primaryContent,
    required this.primaryPic,
    required this.backgroundPic,
    required this.picShape,
    required this.title,
    required this.subtitle,
    required this.secondaryContent,
    required this.secondaryContentBuilder,
    required this.tertiaryContentTitle,
    required this.tertiaryContent,
    required this.tertiaryContentBuilder,
    required this.enableShufflePlay,
    required this.enableSortMethod,
    required this.enableSortOrder,
    required this.enableSecondaryContentViewSwitch,
    this.sortMethods,
    this.multiSelectController,
    this.multiSelectViewActions,
  });

  final PagePreference pref;

  final P primaryContent;

  /// 用来展示内容图片，较高清
  final Future<ImageProvider?> primaryPic;

  /// 当作毛玻璃的背景，较模糊
  final Future<ImageProvider?> backgroundPic;

  final PicShape picShape;

  final String title;
  final String subtitle;

  final List<S> secondaryContent;
  final ContentBuilder<S> secondaryContentBuilder;

  final String tertiaryContentTitle;
  final List<T> tertiaryContent;
  final ContentBuilder<T> tertiaryContentBuilder;

  final bool enableShufflePlay;
  final bool enableSortMethod;
  final bool enableSortOrder;
  final bool enableSecondaryContentViewSwitch;

  final List<SortMethodDesc<S>>? sortMethods;

  final MultiSelectController<S>? multiSelectController;
  final List<Widget>? multiSelectViewActions;

  @override
  State<UniDetailPage<P, S, T>> createState() => _UniDetailPageState<P, S, T>();
}

class _UniDetailPageState<P, S, T> extends State<UniDetailPage<P, S, T>> {
  late SortMethodDesc<S>? currSortMethod =
      widget.sortMethods?[widget.pref.sortMethod];
  late SortOrder currSortOrder = widget.pref.sortOrder;
  late ContentView currContentView = widget.pref.contentView;

  @override
  void initState() {
    super.initState();
    currSortMethod?.method(widget.secondaryContent, currSortOrder);
  }

  @override
  void didUpdateWidget(covariant UniDetailPage<P, S, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    currSortMethod?.method(widget.secondaryContent, currSortOrder);
  }

  void setSortMethod(SortMethodDesc<S> sortMethod) {
    setState(() {
      currSortMethod = sortMethod;
      widget.pref.sortMethod = widget.sortMethods?.indexOf(sortMethod) ?? 0;
      currSortMethod?.method(widget.secondaryContent, currSortOrder);
    });
  }

  void setSortOrder(SortOrder sortOrder) {
    setState(() {
      currSortOrder = sortOrder;
      widget.pref.sortOrder = sortOrder;
      currSortMethod?.method(widget.secondaryContent, currSortOrder);
    });
  }

  void setContentView(ContentView contentView) {
    setState(() {
      currContentView = contentView;
      widget.pref.contentView = contentView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final List<Widget> actions = [];
    if (widget.enableShufflePlay) {
      actions.add(ShufflePlay<S>(contentList: widget.secondaryContent));
    }
    if (widget.enableSortMethod) {
      actions.add(SortMethodComboBox<S>(
        sortMethods: widget.sortMethods!,
        contentList: widget.secondaryContent,
        currSortMethod: currSortMethod!,
        setSortMethod: setSortMethod,
      ));
    }
    if (widget.enableSortOrder) {
      actions.add(SortOrderSwitch<S>(
        sortOrder: currSortOrder,
        setSortOrder: setSortOrder,
      ));
    }
    if (widget.enableSecondaryContentViewSwitch) {
      actions.add(ContentViewSwitch<S>(
        contentView: currContentView,
        setContentView: setContentView,
      ));
    }

    return widget.multiSelectController == null
        ? result(null, actions, scheme)
        : ListenableBuilder(
            listenable: widget.multiSelectController!,
            builder: (context, _) => result(
              widget.multiSelectController!,
              actions,
              scheme,
            ),
          );
  }

  Widget result(MultiSelectController<S>? multiSelectController,
      List<Widget> actions, ColorScheme scheme) {
    return ColoredBox(
      color: scheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // head
            _UniDetailPageHeader(
              pic: widget.primaryPic,
              backgroundPic: widget.backgroundPic,
              picShape: widget.picShape,
              title: widget.title,
              subtitle: widget.subtitle,
              actions: actions,
              multiSelectController: multiSelectController,
              multiSelectViewActions: widget.multiSelectViewActions,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Material(
                borderRadius: BorderRadius.circular(8.0),
                type: MaterialType.transparency,
                child: CustomScrollView(
                  slivers: [
                    // secondary content
                    switch (currContentView) {
                      ContentView.list => SliverFixedExtentList.builder(
                          itemExtent: 64,
                          itemCount: widget.secondaryContent.length,
                          itemBuilder: (context, i) =>
                              widget.secondaryContentBuilder(
                            context,
                            widget.secondaryContent[i],
                            i,
                            multiSelectController,
                          ),
                        ),
                      ContentView.table => SliverGrid.builder(
                          gridDelegate: gridDelegate,
                          itemCount: widget.secondaryContent.length,
                          itemBuilder: (context, i) =>
                              widget.secondaryContentBuilder(
                            context,
                            widget.secondaryContent[i],
                            i,
                            multiSelectController,
                          ),
                        ),
                    },

                    // tertiary content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          widget.tertiaryContentTitle,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SliverList.builder(
                      itemCount: widget.tertiaryContent.length,
                      itemBuilder: (context, i) =>
                          widget.tertiaryContentBuilder(
                        context,
                        widget.tertiaryContent[i],
                        i,
                        null,
                      ),
                    ),
                    const SliverPadding(padding: EdgeInsets.only(bottom: 96.0)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum PicShape { oval, rrect }

class _UniDetailPageHeader extends StatelessWidget {
  const _UniDetailPageHeader({
    required this.pic,
    required this.backgroundPic,
    required this.picShape,
    required this.title,
    required this.subtitle,
    this.multiSelectController,
    required this.actions,
    this.multiSelectViewActions,
  });

  final Future<ImageProvider?> pic;
  final Future<ImageProvider?> backgroundPic;
  final PicShape picShape;

  final String title;
  final String subtitle;
  final MultiSelectController? multiSelectController;
  final List<Widget> actions;
  final List<Widget>? multiSelectViewActions;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final brightness = theme.brightness;
    return SizedBox(
      height: 200,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FutureBuilder(
            future: backgroundPic,
            builder: (context, snapshot) {
              if (snapshot.data == null) return const SizedBox.shrink();

              return Image(
                image: snapshot.data!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              );
            },
          ),
          switch (brightness) {
            Brightness.dark => const ColoredBox(color: Colors.black38),
            Brightness.light => const ColoredBox(color: Colors.white30),
          },
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: const ColoredBox(color: Colors.transparent),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FutureBuilder(
                future: pic,
                builder: (context, snapshot) {
                  final placeholder = Icon(
                    Symbols.broken_image,
                    size: 200.0,
                    color: scheme.onSurface,
                  );
                  return switch (snapshot.connectionState) {
                    ConnectionState.done => snapshot.data == null
                        ? placeholder
                        : switch (picShape) {
                            PicShape.oval => ClipOval(
                                child: Image(
                                  image: snapshot.data!,
                                  width: 200.0,
                                  height: 200.0,
                                  errorBuilder: (_, __, ___) => placeholder,
                                ),
                              ),
                            PicShape.rrect => ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Image(
                                  image: snapshot.data!,
                                  width: 200.0,
                                  height: 200.0,
                                  errorBuilder: (_, __, ___) => placeholder,
                                ),
                              ),
                          },
                    _ => const SizedBox(
                        width: 200,
                        height: 200,
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                  };
                },
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 22.0,
                          color: scheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14.0,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Wrap(
                      spacing: 8.0,
                      runSpacing: 8.0,
                      children: multiSelectController == null
                          ? actions
                          : multiSelectController!.enableMultiSelectView
                              ? multiSelectViewActions!
                              : actions,
                    )
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
