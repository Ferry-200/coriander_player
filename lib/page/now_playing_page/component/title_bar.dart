import 'package:coriander_player/component/title_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:window_manager/window_manager.dart';

class NowPlayingPageTitleBar extends StatelessWidget {
  const NowPlayingPageTitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        const SizedBox(
          height: 48.0,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(child: DragToMoveArea(child: SizedBox.expand())),
                WindowControlls(),
              ],
            ),
          ),
        ),
        SizedBox(
          height: 32.0,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: context.pop,
              child: Center(
                child: Icon(
                  Symbols.arrow_drop_down,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}