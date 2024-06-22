// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:math';

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/lyric/lyric.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/music_api/search_helper.dart';
import 'package:coriander_player/src/bass/bass_player.dart';
import 'package:coriander_player/src/rust/api/smtc_flutter.dart';
import 'package:coriander_player/theme_provider.dart';
// import 'package:coriander_player/windows_toast.dart';
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
  final _smtc = SmtcFlutter();

  PlayService._() {
    _lyricLineStreamController = StreamController.broadcast(onListen: () {
      _lyricLineStreamController.add(_nextLyricLine);
    });
    _subscriptionStreams();
  }

  static PlayService? _instance;

  /// 第一次调用时，创建_instance，订阅stream
  /// 之后直接返回instance
  static PlayService get instance {
    _instance ??= PlayService._();
    return _instance!;
  }

  Audio? nowPlaying;
  ValueNotifier<Lyric?> currentLyric = ValueNotifier(null);

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

  double get volDsp => _bassPlayer.volumeDsp;

  Stream<double> get positionStream => _bassPlayer.positionStream;

  Stream<PlayerState> get playerStateStream => _bassPlayer.playerStateStream;

  Stream<int> get lyricLineStream => _lyricLineStreamController.stream;

  late StreamSubscription _playerStateStreamSub;
  late StreamSubscription _positionStreamSub;
  late StreamSubscription _smtcEventStreamSub;

  void _subscriptionStreams() {
    _playerStateStreamSub = playerStateStream.listen((event) {
      if (event == PlayerState.completed) {
        _autoNextAudio();
      }
    });

    _smtcEventStreamSub = _smtc.subscribeToControlEvents().listen((event) {
      switch (event) {
        case SMTCControlEvent.play:
          start();
          break;
        case SMTCControlEvent.pause:
          pause();
          break;
        case SMTCControlEvent.previous:
          lastAudio();
          break;
        case SMTCControlEvent.next:
          nextAudio();
          break;
        case SMTCControlEvent.unknown:
      }
    });

    /// update next lyric line here
    _positionStreamSub = positionStream.listen((pos) {
      if (currentLyric.value == null) return;
      if (_nextLyricLine >= currentLyric.value!.lines.length) return;

      if ((pos * 1000) >
          currentLyric.value!.lines[_nextLyricLine].start.inMilliseconds) {
        _nextLyricLine += 1;
        _lyricLineStreamController.add(_nextLyricLine - 1);
      }
    });
  }

  Future<Lyric?> _getLyricDefault({required bool localFirst}) async {
    if (localFirst) {
      return (await Lrc.fromAudioPath(nowPlaying!)) ??
          (await getMostMatchedLyric(nowPlaying!));
    }
    return (await getMostMatchedLyric(nowPlaying!).timeout(
          const Duration(seconds: 5),
          onTimeout: () async => await Lrc.fromAudioPath(nowPlaying!),
        )) ??
        (await Lrc.fromAudioPath(nowPlaying!));
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

    currentLyric.value = null;

    /// 读取本地默认歌词来源：
    /// 1. 如果没有指定来源，按照现在的方式寻找歌词（本地 -> 在线）
    /// 2. 如果指定来源，按照指定的来源获取
    final lyricSource = LYRIC_SOURCES[nowPlaying!.path];
    if (lyricSource == null) {
      _getLyricDefault(localFirst: AppSettings.instance.localLyricFirst)
          .then((value) {
        if (value != null && value.belongTo == nowPlaying) {
          currentLyric.value = value;
        }
      });
    } else {
      if (lyricSource.source == LyricSourceType.local) {
        Lrc.fromAudioPath(nowPlaying!).then((value) {
          if (value != null && value.belongTo == nowPlaying) {
            currentLyric.value = value;
          }
        });
      } else {
        getOnlineLyric(
          belongTo: nowPlaying!,
          qqSongId: lyricSource.qqSongId,
          kugouSongHash: lyricSource.kugouSongHash,
          neteaseSongId: lyricSource.neteaseSongId,
        ).then((value) {
          if (value != null && value.belongTo == nowPlaying) {
            currentLyric.value = value;
          }
        });
      }
    }

    _nextLyricLine = 0;

    _bassPlayer.start();
    notifyListeners();
    ThemeProvider.instance.applyThemeFromAudio(nowPlaying!);

    _smtc.updateState(state: SMTCState.playing);
    _smtc.updateDisplay(
      title: nowPlaying!.title,
      artist: nowPlaying!.artist,
      album: nowPlaying!.album,
      path: nowPlaying!.path,
    );
  }

  /// 修改解码时的音量（不影响 Windows 系统音量）
  void setVolumeDsp(double volume) => _bassPlayer.setVolumeDsp(volume);

  void useEmbeddedLyric() {
    currentLyric.value = null;
    _nextLyricLine = 0;
    Lrc.fromAudioPath(nowPlaying!).then((value) {
      if (value != null && value.belongTo == nowPlaying) {
        currentLyric.value = value;
        _findCurrLyricLine();
      }
    });
  }

  void useOnlineLyric() {
    currentLyric.value = null;
    _nextLyricLine = 0;
    getMostMatchedLyric(nowPlaying!).then((value) {
      if (value != null && value.belongTo == nowPlaying) {
        currentLyric.value = value;
        _findCurrLyricLine();
      }
    });
  }

  /// 重新计算歌词进行到第几行
  void _findCurrLyricLine() {
    if (currentLyric.value == null) return;

    final next = currentLyric.value!.lines.indexWhere(
      (element) => element.start.inMilliseconds / 1000 > position,
    );
    _nextLyricLine = next == -1 ? currentLyric.value!.lines.length : next;
    _lyricLineStreamController.add(max(_nextLyricLine - 1, 0));
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
    if (_nowPlayingIndex == null) return;
    _playAfterLoaded(_nowPlayingIndex!, playlist);
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
  void pause() {
    _bassPlayer.pause();
    _smtc.updateState(state: SMTCState.paused);
  }

  /// 恢复播放
  void start() {
    _bassPlayer.start();
    _smtc.updateState(state: SMTCState.playing);
  }

  /// 再次播放。在顺序播放完最后一曲时再次按播放时使用。
  /// 与[start]的差别在于它会通知重绘组件
  void playAgain() => _nextAudio_singleLoop();

  /// update [_nextLyricLine]
  void seek(double position) {
    _bassPlayer.seek(position);
    _findCurrLyricLine();
  }

  Future<void> close() async {
    _bassPlayer.free();
    await _lyricLineStreamController.close();
    await _playerStateStreamSub.cancel();
    await _positionStreamSub.cancel();
    await _smtcEventStreamSub.cancel();
    await _smtc.close();
  }
}
