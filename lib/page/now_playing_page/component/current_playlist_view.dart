import 'package:coriander_player/play_service.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CurrentPlaylistView extends StatefulWidget {
  const CurrentPlaylistView({super.key});

  @override
  State<CurrentPlaylistView> createState() => _CurrentPlaylistViewState();
}

class _CurrentPlaylistViewState extends State<CurrentPlaylistView> {
  final playService = PlayService.instance;
  late final ScrollController scrollController;

  void _toNowPlaying() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        playService.nowPlayingIndex * 56.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.fastOutSlowIn,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController(
      initialScrollOffset: playService.nowPlayingIndex * 56.0,
    );
    playService.addListener(_toNowPlaying);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

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
                color: theme.scheme.onSecondaryContainer,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: PlayService.instance.shuffle,
              builder: (context, _) {
                return ListView.builder(
                  controller: scrollController,
                  itemCount: playService.playlist.length,
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
    playService.removeListener(_toNowPlaying);
    scrollController.dispose();
  }
}

class _PlaylistViewItem extends StatelessWidget {
  const _PlaylistViewItem({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    var playService = PlayService.instance;
    final item = playService.playlist[index];
    final theme = Provider.of<ThemeProvider>(context);
    return InkWell(
      borderRadius: BorderRadius.circular(8.0),
      hoverColor: theme.scheme.onSecondaryContainer.withOpacity(0.08),
      highlightColor: theme.scheme.onSecondaryContainer.withOpacity(0.12),
      splashColor: theme.scheme.onSecondaryContainer.withOpacity(0.12),
      onTap: () {
        playService.playIndexOfPlaylist(index);
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: DefaultTextStyle(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: theme.scheme.onSecondaryContainer,
            fontSize: 14,
          ),
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
