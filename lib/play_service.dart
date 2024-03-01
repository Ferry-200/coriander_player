// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:coriander_player/audio_library.dart';
import 'package:coriander_player/lyric.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/widgets.dart';

enum PlayMode {
  /// 顺序播放到播放列表结尾
  forward,

  /// 循环整个播放列表
  loop,

  /// 循环播放单曲
  singleLoop,
}

/// 确保只有在切换歌曲时通知listener
class PlayService with ChangeNotifier {
  final BassPlayer _bassPlayer = BassPlayer();

  PlayService._() {
    _lyricLineStreamController = StreamController.broadcast(onListen: () {
      _lyricLineStreamController.add(_nextLyricLine);
    });
  }

  static PlayService? _instance;

  /// 第一次调用时，创建_instance，订阅stream
  /// 之后直接返回instance
  static PlayService get instance {
    if (_instance == null) {
      _instance = PlayService._();
      _instance!._subscriptionStreams();
    }
    return _instance!;
  }

  Audio? nowPlaying;
  Lyric? nowPlayingLyric;

  /// 下一行歌词
  int _nextLyricLine = 0;
  late final StreamController<int> _lyricLineStreamController;

  /// 用来实现下一曲/上一曲等操作
  int? _nowPlayingIndex;
  int get nowPlayingIndex => _nowPlayingIndex ?? 0;

  /// 当前播放列表
  List<Audio> playlist = [];

  /// 每一次设置playlist时都备份，在切换是否随机播放时回复之前的播放列表。
  /// 读取备份时必须使用playlist = List.from(_playlistBackup)
  List<Audio> _playlistBackup = [];

  ValueNotifier<PlayMode> playMode = ValueNotifier(PlayMode.forward);
  ValueNotifier<bool> shuffle = ValueNotifier(false);

  double get length => _bassPlayer.length;

  double get position => _bassPlayer.position;

  PlayerState get playerState => _bassPlayer.playerState;

  Stream<double> get positionStream => _bassPlayer.positionStream;

  Stream<PlayerState> get playerStateStream => _bassPlayer.playerStateStream;

  Stream<int> get lyricLineStream => _lyricLineStreamController.stream;

  late StreamSubscription _playerStateStreamSub;
  late StreamSubscription _positionStreamSub;

  void _subscriptionStreams() {
    _playerStateStreamSub = playerStateStream.listen((event) {
      if (event == PlayerState.completed) {
        _autoNextAudio();
      }
    });

    /// update next lyric line here
    _positionStreamSub = positionStream.listen((pos) {
      if (nowPlayingLyric == null) return;
      if (_nextLyricLine >= nowPlayingLyric!.lines.length) return;

      if ((pos * 1000) >
          nowPlayingLyric!.lines[_nextLyricLine].time.inMilliseconds) {
        _nextLyricLine += 1;
        _lyricLineStreamController.add(max(_nextLyricLine - 1, 0));
      }
    });
  }

  /// 1. 更新[_nowPlayingIndex]为[audioIndex]
  /// 2. 更新[nowPlaying]为playlist[_nowPlayingIndex]
  /// 3. _bassPlayer.setSource
  /// 4. 获取歌词 **将[_nextLyricLine]置为0**
  /// 5. 播放
  /// 6. 通知并更新主题色
  void _playAfterLoaded(int audioIndex, List<Audio> playlist) {
    _nowPlayingIndex = audioIndex;
    nowPlaying = playlist[audioIndex];
    _bassPlayer.setSource(nowPlaying!.path);

    Lyric.fromAudioPath(nowPlaying!.path, separator: "┃").then((value) {
      nowPlayingLyric = value;
      notifyListeners();
    });
    _nextLyricLine = 0;

    _bassPlayer.start();
    notifyListeners();
    ThemeProvider.instance.setPalleteFromAudio(nowPlaying!);
  }

  /// 播放当前播放列表的第几项，只能用在播放列表界面
  void playIndexOfPlaylist(int audioIndex) {
    _playAfterLoaded(audioIndex, playlist);
  }

  /// 播放playlist[audioIndex]并设置播放列表为playlist
  void play(int audioIndex, List<Audio> playlist) {
    _playAfterLoaded(audioIndex, playlist);

    this.playlist = List.from(playlist);
    _playlistBackup = List.from(playlist);
  }

  void shuffleAndPlay(List<Audio> audios) {
    playlist = List.from(audios);
    playlist.shuffle();
    _playlistBackup = List.from(audios);

    shuffle.value = true;

    _playAfterLoaded(0, playlist);
  }

  void toggleShuffle() {
    if (nowPlaying == null) return;

    if (shuffle.value) {
      shuffle.value = false;
      playlist = List.from(_playlistBackup);
      _nowPlayingIndex = playlist.indexOf(nowPlaying!);
    } else {
      shuffle.value = true;
      playlist.shuffle();
      _nowPlayingIndex = playlist.indexOf(nowPlaying!);
    }
  }

  void _autoNextAudio() {
    switch (playMode.value) {
      case PlayMode.forward:
        _nextAudio_forward();
        break;
      case PlayMode.loop:
        _nextAudio_loop();
        break;
      case PlayMode.singleLoop:
        _nextAudio_singleLoop();
        break;
    }
  }

  void _nextAudio_forward() {
    if (_nowPlayingIndex == null) {
      return;
    }
    if (_nowPlayingIndex! < playlist.length - 1) {
      _playAfterLoaded(_nowPlayingIndex! + 1, playlist);
    }
  }

  void _nextAudio_loop() {
    if (_nowPlayingIndex == null) {
      return;
    }
    int newIndex = _nowPlayingIndex! + 1;
    if (newIndex >= playlist.length) {
      newIndex = 0;
    }

    _playAfterLoaded(newIndex, playlist);
  }

  void _nextAudio_singleLoop() {
    _bassPlayer.start();
    notifyListeners();
  }

  /// 手动下一曲时默认循环播放列表
  void nextAudio() {
    if (_nowPlayingIndex == null) {
      return;
    }
    int newIndex = _nowPlayingIndex! + 1;
    if (newIndex >= playlist.length) {
      newIndex = 0;
    }

    _playAfterLoaded(newIndex, playlist);
  }

  /// 手动上一曲时默认循环播放列表
  void lastAudio() {
    if (_nowPlayingIndex == null) {
      return;
    }
    int newIndex = _nowPlayingIndex! - 1;
    if (newIndex < 0) {
      newIndex = playlist.length - 1;
    }

    _playAfterLoaded(newIndex, playlist);
  }

  /// 暂停
  void pause() => _bassPlayer.pause();

  /// 恢复播放
  void start() => _bassPlayer.start();

  /// 再次播放。在顺序播放完最后一曲时再次按播放时使用。
  /// 与[start]的差别在于它会通知重绘组件
  void playAgain() {
    _bassPlayer.start();
    _nextLyricLine = 0;
    notifyListeners();
  }

  /// update [_nextLyricLine]
  void seek(double position) {
    _bassPlayer.seek(position);

    if (nowPlayingLyric == null) return;

    final next = nowPlayingLyric!.lines.indexWhere(
      (element) => element.time.inMilliseconds / 1000 > position,
    );
    _nextLyricLine = next == -1 ? nowPlayingLyric!.lines.length : next;
    _lyricLineStreamController.add(max(_nextLyricLine - 1, 0));
  }

  @override
  void dispose() {
    super.dispose();
    _bassPlayer.free();
    _lyricLineStreamController.close();
    _playerStateStreamSub.cancel();
    _positionStreamSub.cancel();
  }
}
