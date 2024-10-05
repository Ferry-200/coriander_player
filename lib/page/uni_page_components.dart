import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/page/uni_page.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ShufflePlay<T> extends StatelessWidget {
  final List<T> contentList;
  const ShufflePlay({super.key, required this.contentList});

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: () => PlayService.instance.playbackService.shuffleAndPlay(
        contentList as List<Audio>,
      ),
      icon: const Icon(Symbols.shuffle),
      label: const Text("随机播放"),
      style: const ButtonStyle(
        fixedSize: WidgetStatePropertyAll(Size.fromHeight(40)),
      ),
    );
  }
}

class SortMethodComboBox<T> extends StatelessWidget {
  final List<T> contentList;
  final List<SortMethodDesc<T>> sortMethods;
  final SortMethodDesc<T> currSortMethod;
  final void Function(SortMethodDesc<T> sortMethod) setSortMethod;
  const SortMethodComboBox({
    super.key,
    required this.sortMethods,
    required this.contentList,
    required this.currSortMethod,
    required this.setSortMethod,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      menuChildren: List.generate(
        sortMethods.length,
        (i) => MenuItemButton(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(EdgeInsets.all(12)),
          ),
          leadingIcon: Icon(sortMethods[i].icon),
          child: Text(sortMethods[i].name),
          onPressed: () => setSortMethod(sortMethods[i]),
        ),
      ),
      builder: (context, menuController, _) {
        final borderRadius = BorderRadius.circular(20.0);

        return SizedBox(
          height: 40.0,
          child: Material(
            borderRadius: borderRadius,
            color: scheme.secondaryContainer,
            child: InkWell(
              hoverColor: scheme.onSecondaryContainer.withOpacity(0.08),
              borderRadius: borderRadius,
              onTap: () {
                if (menuController.isOpen) {
                  menuController.close();
                } else {
                  menuController.open();
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Symbols.sort,
                      size: 24,
                      color: scheme.onSecondaryContainer,
                    ),
                    const SizedBox(width: 4.0),
                    Text(
                      currSortMethod.name,
                      style: TextStyle(color: scheme.onSecondaryContainer),
                    ),
                    const SizedBox(width: 4.0),
                    Icon(
                      Symbols.arrow_drop_down,
                      size: 24,
                      color: scheme.onSecondaryContainer,
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

class SortOrderSwitch<T> extends StatelessWidget {
  final SortOrder sortOrder;
  final void Function(SortOrder order) setSortOrder;
  const SortOrderSwitch(
      {super.key, required this.sortOrder, required this.setSortOrder});

  @override
  Widget build(BuildContext context) {
    var isAscending = sortOrder == SortOrder.ascending;
    return IconButton.filledTonal(
      tooltip: "切换排序顺序；现在：${isAscending ? "升序" : "降序"}",
      onPressed: () => setSortOrder(
        isAscending ? SortOrder.decending : SortOrder.ascending,
      ),
      icon: Icon(isAscending ? Symbols.arrow_upward : Symbols.arrow_downward),
    );
  }
}

class ContentViewSwitch<T> extends StatelessWidget {
  final ContentView contentView;
  final void Function(ContentView contentView) setContentView;
  const ContentViewSwitch(
      {super.key, required this.contentView, required this.setContentView});

  @override
  Widget build(BuildContext context) {
    var isListView = contentView == ContentView.list;
    return IconButton.filledTonal(
      tooltip: "切换页面视图；现在：${isListView ? "列表" : "表格"}",
      onPressed: () => setContentView(
        isListView ? ContentView.table : ContentView.list,
      ),
      icon: Icon(isListView ? Symbols.list : Symbols.table),
    );
  }
}

class AddAllToPlaylist extends StatelessWidget {
  const AddAllToPlaylist({super.key, required this.multiSelectController});

  final MultiSelectController<Audio> multiSelectController;

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      style: MenuStyle(
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      menuChildren: List.generate(
        PLAYLISTS.length,
        (i) => MenuItemButton(
          style: const ButtonStyle(
            padding: WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
          onPressed: () {
            for (var item in multiSelectController.selected) {
              if (!PLAYLISTS[i].audios.containsKey(item.path)) {
                PLAYLISTS[i].audios[item.path] = item;
              }
            }
            showTextOnSnackBar(
              "成功将${multiSelectController.selected.length}首添加到歌单“${PLAYLISTS[i].name}”",
            );
          },
          child: Text(PLAYLISTS[i].name),
        ),
      ),
      builder: (context, controller, _) => FilledButton.icon(
        onPressed: () {
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
        icon: const Icon(Symbols.add),
        label: const Text("添加到歌单"),
        style: const ButtonStyle(
          fixedSize: WidgetStatePropertyAll(Size.fromHeight(40)),
        ),
      ),
    );
  }
}

class MultiSelectSelectOrClearAll<T> extends StatelessWidget {
  final MultiSelectController<T> multiSelectController;
  final List<T> contentList;

  const MultiSelectSelectOrClearAll(
      {super.key,
      required this.multiSelectController,
      required this.contentList});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: multiSelectController,
      builder: (context, _) => IconButton.filledTonal(
        tooltip: multiSelectController.selected.isEmpty ? "全选" : "取消全选",
        onPressed: () {
          if (multiSelectController.selected.isEmpty) {
            multiSelectController.selectAll(contentList);
          } else {
            multiSelectController.clear();
          }
        },
        icon: Icon(
          multiSelectController.selected.isEmpty
              ? Symbols.select_all
              : Symbols.clear_all,
        ),
      ),
    );
  }
}

class MultiSelectExit<T> extends StatelessWidget {
  final MultiSelectController<T> multiSelectController;

  const MultiSelectExit({super.key, required this.multiSelectController});

  @override
  Widget build(BuildContext context) {
    return IconButton.filledTonal(
      tooltip: "退出多选视图",
      onPressed: () {
        multiSelectController.useMultiSelectView(false);
        multiSelectController.clear();
      },
      icon: const Icon(Symbols.cancel),
    );
  }
}
