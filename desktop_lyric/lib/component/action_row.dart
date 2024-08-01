import 'dart:io';

import 'package:desktop_lyric/message.dart';
import 'package:desktop_lyric/player_states.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ActionRow extends StatelessWidget {
  const ActionRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeChangedMessage>();
    const spacer = SizedBox(width: 8);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            stdout.write(PlayerActionMessage(
              action: PlayerAction.PREVIOUS_AUDIO,
            ));
          },
          color: theme.onSurface,
          icon: const Icon(Icons.skip_previous),
        ),
        spacer,
        ValueListenableBuilder(
          valueListenable: PlayerStates.instance.playerAction,
          builder: (context, playerAction, _) => IconButton(
            onPressed: () {
              stdout.write(PlayerActionMessage(
                action: playerAction == PlayerAction.START
                    ? PlayerAction.PAUSE
                    : PlayerAction.START,
              ));
            },
            color: theme.onSurface,
            icon: Icon(
              playerAction == PlayerAction.START
                  ? Icons.pause
                  : Icons.play_arrow,
            ),
          ),
        ),
        spacer,
        IconButton(
          onPressed: () {
            stdout.write(PlayerActionMessage(
              action: PlayerAction.NEXT_AUDIO,
            ));
          },
          color: theme.onSurface,
          icon: const Icon(Icons.skip_next),
        ),
        spacer,
        IconButton(
          onPressed: () {
            stdout.write(PlayerActionMessage(
              action: PlayerAction.CLOSE_DESKTOP_LYRIC,
            ));
          },
          color: theme.onSurface,
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
