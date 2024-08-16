import 'package:coriander_player/play_service/play_service.dart';
import 'package:flutter/material.dart';

class CurrentPlaylistView extends StatefulWidget {
  const CurrentPlaylistView({super.key});

  @override
  State<CurrentPlaylistView> createState() => _CurrentPlaylistViewState();
}

class _CurrentPlaylistViewState extends State<CurrentPlaylistView> {
  final playbackService = PlayService.instance.playbackService;
  late final ScrollController scrollController;

  void _toNowPlaying() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        playbackService.playlistIndex * 56.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      initialScrollOffset: playbackService.playlistIndex * 56.0,
    );
    playbackService.addListener(_toNowPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Material(
      type: MaterialType.transparency,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "播放列表",
              style: TextStyle(
                color: scheme.onSecondaryContainer,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: playbackService.shuffle,
              builder: (context, _) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: playbackService.playlist.value.length,
                  itemExtent: 56.0,
                  itemBuilder: (context, index) {
                    return _PlaylistViewItem(index: index);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    playbackService.removeListener(_toNowPlaying);
    scrollController.dispose();
  }
}

class _PlaylistViewItem extends StatelessWidget {
  const _PlaylistViewItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    var playbackService = PlayService.instance.playbackService;
    final item = playbackService.playlist.value[index];
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      onTap: () {
        playbackService.playIndexOfPlaylist(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: scheme.onSecondaryContainer, fontSize: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title),
              Text("${item.artist} - ${item.album}"),
            ],
          ),
        ),
      ),
    );
  }
}
