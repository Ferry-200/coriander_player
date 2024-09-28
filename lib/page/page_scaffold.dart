import 'package:coriander_player/component/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// title, actions, body
///
/// 提供基本的响应式布局：
///
/// 小屏幕时，折叠第一个组件以外的其他组件。后两个放在同一行；
/// 若 action 总数大于 3，把第二个起倒数第三个为止的组件相继放在下面。
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.actions,
    required this.body,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return ResponsiveBuilder(builder: (context, screenType) {
      List<Widget> rowChildren;

      if (actions.isEmpty) {
        rowChildren =
            subtitle == null ? [onlyTitle(scheme)] : [withSubtitle(scheme)];
      } else {
        switch (screenType) {
          case ScreenType.small:
            {
              final List<Widget> foldedRow1 = [];
              int count = 0;
              for (int i = actions.length - 1;
                  i > 0 && count < 2;
                  --i, ++count) {
                if (count == 1) foldedRow1.add(const SizedBox(width: 8.0));

                foldedRow1.add(actions[i]);
              }

              final List<Widget> foldedColumn = [];
              if (foldedRow1.isNotEmpty) {
                foldedColumn.add(Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: foldedRow1,
                ));
              }

              if (actions.length >= 4) {
                for (var i = actions.length - 1 - count; i > 0; --i) {
                  foldedColumn.add(actions[i]);
                }
              }

              final menuStyle = MenuStyle(
                shape: WidgetStatePropertyAll(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );

              rowChildren = [
                subtitle == null ? onlyTitle(scheme) : withSubtitle(scheme),
                const SizedBox(width: 16.0),
                actions.first,
                if (foldedColumn.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: MenuAnchor(
                      style: menuStyle,
                      menuChildren: foldedColumn,
                      builder: (_, controller, __) => IconButton.filledTonal(
                        tooltip: "更多",
                        onPressed: () {
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        },
                        icon: const Icon(Symbols.more_vert),
                      ),
                    ),
                  ),
              ];
              break;
            }
          case ScreenType.medium:
          case ScreenType.large:
            {
              rowChildren = [
                subtitle == null ? onlyTitle(scheme) : withSubtitle(scheme),
                const SizedBox(width: 16.0),
                Wrap(spacing: 8.0, children: actions)
              ];
            }
        }
      }

      return ColoredBox(
        color: scheme.surface,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: rowChildren,
                ),
              ),
              Expanded(child: body),
            ],
          ),
        ),
      );
    });
  }

  Expanded onlyTitle(ColorScheme scheme) {
    return Expanded(
      child: Text(
        title,
        style: TextStyle(fontSize: 32.0, color: scheme.onSurface),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Expanded withSubtitle(ColorScheme scheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 28.0, color: scheme.onSurface),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle!,
            style: TextStyle(fontSize: 14.0, color: scheme.onSurface),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
