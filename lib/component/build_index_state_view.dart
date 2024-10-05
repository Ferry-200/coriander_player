import 'dart:async';
import 'dart:io';

import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';

class BuildIndexStateView extends StatefulWidget {
  const BuildIndexStateView(
      {super.key,
      required this.indexPath,
      required this.folders,
      required this.whenIndexBuilt});

  final Directory indexPath;
  final List<String> folders;
  final void Function() whenIndexBuilt;

  @override
  State<BuildIndexStateView> createState() => _BuildIndexStateViewState();
}

class _BuildIndexStateViewState extends State<BuildIndexStateView> {
  late final Stream<IndexActionState> buildIndexStream;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    buildIndexStream = buildIndexFromFoldersRecursively(
      folders: widget.folders,
      indexPath: widget.indexPath.path,
    ).asBroadcastStream();

    _subscription = buildIndexStream.listen(
      (action) {
        LOGGER.i("[build index] ${action.progress}: ${action.message}");
      },
      onDone: () {
        widget.whenIndexBuilt();
        _subscription?.cancel();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: buildIndexStream,
      builder: (context, snapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            LinearProgressIndicator(
              value: snapshot.data?.progress,
              borderRadius: BorderRadius.circular(2.0),
            ),
            const SizedBox(height: 8.0),
            Text(
              "${snapshot.data?.message}",
              style: TextStyle(color: scheme.onSurface),
            ),
          ],
        );
      },
    );
  }
}
