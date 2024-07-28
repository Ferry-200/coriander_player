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
  final Future<ImageProvider?> primaryPic;
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
  late ContentView currContentView =
      widget.pref.contentView;

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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(8.0),
          bottomRight: Radius.circular(8.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // head
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _PrimaryContentPicture(
                  pic: widget.primaryPic,
                  picShape: widget.picShape,
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Flexible(
                        child: Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 22.0,
                            color: scheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        widget.subtitle,
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
                            : multiSelectController.enableMultiSelectView
                                ? widget.multiSelectViewActions!
                                : actions,
                      )
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: Material(
                color: scheme.surface,
                child: CustomScrollView(
                  slivers: [
                    // secondary content
                    switch (currContentView) {
                      ContentView.list => SliverList.builder(
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
                            fontWeight: FontWeight.w600,
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

class _PrimaryContentPicture extends StatelessWidget {
  const _PrimaryContentPicture(
      {super.key, required this.pic, required this.picShape});

  final Future<ImageProvider?> pic;
  final PicShape picShape;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: pic,
      builder: (context, snapshot) {
        final scheme = Theme.of(context).colorScheme;
        final placeholder = Icon(
          Symbols.broken_image,
          size: 200.0,
          color: scheme.onSurface,
        );
        if (snapshot.data == null) {
          return Flexible(
            child: placeholder,
          );
        }
        return switch (picShape) {
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
        };
      },
    );
  }
}
