import 'package:coriander_player/component/responsive_builder.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// title, actions, body
class PageScaffold extends StatelessWidget {
  const PageScaffold({
    super.key,
    required this.title,
    required this.actions,
    required this.body,
  });

  final String title;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    late List<Widget> rowChildren;
    if (actions.isEmpty) {
      rowChildren = [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 32.0,
              color: theme.palette.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ];
    } else {
      rowChildren = [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 32.0,
              color: theme.palette.onSurface,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 16.0),
        Wrap(spacing: 8.0, children: actions)
      ];
    }

    return ResponsiveBuilder(builder: (context, screenType) {
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
}
