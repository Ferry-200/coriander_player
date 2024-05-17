import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

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
    final theme = Provider.of<ThemeProvider>(context);

    return ResponsiveBuilder(builder: (context, screenType) {
      List<Widget> rowChildren;

      if (actions.isEmpty) {
        rowChildren =
            subtitle == null ? [onlyTitle(theme)] : [withSubtitle(theme)];
      } else {
        switch (screenType) {
          case ScreenType.small:
            {
              final List<Widget> foldedRow1 = [];
              for (int i = actions.length - 1, count = 0;
                  i > 0 && count < 2;
                  --i) {
                if (count > 0) foldedRow1.add(const SizedBox(width: 8.0));

                foldedRow1.add(actions[i]);
                count++;
              }

              final List<Widget> foldedColumn = [
                SizedBox(
                  height: 40,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: foldedRow1,
                  ),
                ),
              ];

              if (actions.length >= 4) {
                for (var i = 1; i < actions.length - 2; ++i) {
                  foldedColumn.add(actions[i]);
                }
              }

              final menuStyle = MenuStyle(
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20))),
                backgroundColor:
                    WidgetStatePropertyAll(theme.palette.surfaceContainer),
                surfaceTintColor:
                    WidgetStatePropertyAll(theme.palette.surfaceContainer),
              );

              rowChildren = [
                subtitle == null ? onlyTitle(theme) : withSubtitle(theme),
                const SizedBox(width: 16.0),
                actions.first,
                const SizedBox(width: 16.0),
                MenuAnchor(
                  style: menuStyle,
                  menuChildren: foldedColumn,
                  builder: (context, controller, _) => IconButton.filled(
                    style: theme.secondaryIconButtonStyle,
                    onPressed: () {
                      controller.isOpen
                          ? controller.close()
                          : controller.open();
                    },
                    icon: const Icon(Symbols.more_vert),
                  ),
                ),
              ];
              break;
            }
          case ScreenType.medium:
          case ScreenType.large:
            {
              rowChildren = [
                subtitle == null ? onlyTitle(theme) : withSubtitle(theme),
                const SizedBox(width: 16.0),
                Wrap(spacing: 8.0, children: actions)
              ];
            }
        }
      }

      return DecoratedBox(
        decoration: BoxDecoration(
          color: theme.palette.surface,
          borderRadius: BorderRadius.only(
            topLeft: screenType == ScreenType.small
                ? Radius.zero
                : const Radius.circular(8.0),
            bottomRight: const Radius.circular(8.0),
          ),
        ),
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

  Expanded onlyTitle(ThemeProvider theme) {
    return Expanded(
      child: Text(
        title,
        style: TextStyle(
          fontSize: 32.0,
          color: theme.palette.onSurface,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Expanded withSubtitle(ThemeProvider theme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 28.0,
              color: theme.palette.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 14.0,
              color: theme.palette.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          )
        ],
      ),
    );
  }
}
