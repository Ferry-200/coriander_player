import 'dart:async';
import 'dart:io';

import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/src/rust/api/tag_reader.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;

class UpdatingPage extends StatelessWidget {
  const UpdatingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Center(
        child: FutureBuilder(
          future: getApplicationSupportDirectory(),
          builder: (context, snapshot) {
            if (snapshot.data == null) return const SizedBox.shrink();

            return UpdatingStateView(indexPath: snapshot.data!);
          },
        ),
      ),
    );
  }
}

class UpdatingStateView extends StatefulWidget {
  const UpdatingStateView({super.key, required this.indexPath});

  final Directory indexPath;

  @override
  State<UpdatingStateView> createState() => _UpdatingStateViewState();
}

class _UpdatingStateViewState extends State<UpdatingStateView> {
  Widget? currDisplay;
  StreamSubscription? _subscription;

  void whenIndexUpdated() {
    setState(() {
      currDisplay = SizedBox(
        width: 400,
        child: LinearProgressIndicator(
          borderRadius: BorderRadius.circular(2.0),
        ),
      );
    });

    Future.wait([
      AudioLibrary.initFromIndex(),
      readPlaylists(),
      readLyricSources(),
    ]).whenComplete(() {
      _subscription?.cancel();
      context.go(app_paths.AUDIOS_PAGE);
    });
  }

  @override
  void initState() {
    super.initState();
    final updateIndexStream = updateIndex(
      indexPath: widget.indexPath.path,
    ).asBroadcastStream();

    _subscription = updateIndexStream.listen(null, onDone: whenIndexUpdated);
    currDisplay = UpdatingIndexView(stream: updateIndexStream);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: currDisplay,
    );
  }
}

class UpdatingIndexView extends StatelessWidget {
  const UpdatingIndexView({super.key, required this.stream});

  final Stream stream;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return StreamBuilder(
      stream: stream,
      builder: (context, snapshot) {
        return Wrap(
          direction: Axis.vertical,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8.0,
          children: [
            SizedBox(
              width: 400,
              child: LinearProgressIndicator(
                value: snapshot.data?.progress,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
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
