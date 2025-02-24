part of 'page.dart';

class _NowPlayingPage_Small extends StatefulWidget {
  const _NowPlayingPage_Small();

  @override
  State<_NowPlayingPage_Small> createState() => _NowPlayingPage_SmallState();
}

class _NowPlayingPage_SmallState extends State<_NowPlayingPage_Small> {
  static const viewOnlyMain = [
    NowPlayingViewMode.withPlaylist,
    NowPlayingViewMode.onlyMain,
    NowPlayingViewMode.withLyric,
  ];
  static const viewWithLyric = [
    NowPlayingViewMode.onlyMain,
    NowPlayingViewMode.withLyric,
    NowPlayingViewMode.withPlaylist,
  ];
  static const viewWithPlaylist = [
    NowPlayingViewMode.withLyric,
    NowPlayingViewMode.withPlaylist,
    NowPlayingViewMode.onlyMain,
  ];
  late var views =
      switch (AppPreference.instance.nowPlayingPagePref.nowPlayingViewMode) {
    NowPlayingViewMode.onlyMain => viewOnlyMain,
    NowPlayingViewMode.withLyric => viewWithLyric,
    NowPlayingViewMode.withPlaylist => viewWithPlaylist,
  };

  IconData viewSwitchIcon(NowPlayingViewMode viewMode) {
    return switch (viewMode) {
      NowPlayingViewMode.onlyMain => Symbols.music_note,
      NowPlayingViewMode.withLyric => Symbols.lyrics,
      NowPlayingViewMode.withPlaylist => Symbols.queue_music,
    };
  }

  void changeView(NowPlayingViewMode viewMode) {
    late final List<NowPlayingViewMode> desView;
    switch (viewMode) {
      case NowPlayingViewMode.onlyMain:
        desView = viewOnlyMain;
        break;
      case NowPlayingViewMode.withLyric:
        desView = viewWithLyric;
        break;
      case NowPlayingViewMode.withPlaylist:
        desView = viewWithPlaylist;
        break;
    }
    setState(() {
      views = desView;
    });
    NOW_PLAYING_VIEW_MODE.value = viewMode;
    AppPreference.instance.nowPlayingPagePref.nowPlayingViewMode = viewMode;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NowPlayingSmallViewSwitch(
                  onTap: () => changeView(views[0]),
                  icon: viewSwitchIcon(views[0]),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    child: switch (views[1]) {
                      NowPlayingViewMode.onlyMain => const _NowPlayingInfo(),
                      NowPlayingViewMode.withLyric => const VerticalLyricView(),
                      NowPlayingViewMode.withPlaylist =>
                        const CurrentPlaylistView(),
                    },
                  ),
                ),
                _NowPlayingSmallViewSwitch(
                  onTap: () => changeView(views[2]),
                  icon: viewSwitchIcon(views[2]),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _NowPlayingSlider(),
          ),
          const SizedBox(height: 8.0),
          const _NowPlayingMainControls(),
          const SizedBox(height: 8.0),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NowPlayingShuffleSwitch(),
              _NowPlayingPlayModeSwitch(),
              _NowPlayingVolDspSlider(),
              _ExclusiveModeSwitch(),
              _DesktopLyricSwitch(),
              _NowPlayingMoreAction(),
            ],
          )
        ],
      ),
    );
  }
}

class _NowPlayingSmallViewSwitch extends StatefulWidget {
  const _NowPlayingSmallViewSwitch({required this.onTap, required this.icon});

  final void Function() onTap;
  final IconData icon;

  @override
  State<_NowPlayingSmallViewSwitch> createState() =>
      _NowPlayingSmallViewSwitchState();
}

class _NowPlayingSmallViewSwitchState
    extends State<_NowPlayingSmallViewSwitch> {
  bool visible = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        width: 32,
        child: Material(
          borderRadius: BorderRadius.circular(16.0),
          type: MaterialType.transparency,
          child: Opacity(
            opacity: visible ? 1.0 : 0.0,
            child: InkWell(
              borderRadius: BorderRadius.circular(16.0),
              hoverColor: scheme.onSecondaryContainer.withOpacity(0.08),
              highlightColor: scheme.onSecondaryContainer.withOpacity(0.12),
              splashColor: scheme.onSecondaryContainer.withOpacity(0.12),
              onTap: widget.onTap,
              onHover: (hasEntered) {
                setState(() {
                  visible = hasEntered;
                });
              },
              child: Center(
                child: Icon(
                  widget.icon,
                  color: scheme.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
