import 'package:coriander_player/play_service/desktop_lyric_service.dart';
import 'package:coriander_player/play_service/lyric_service.dart';
import 'package:coriander_player/play_service/playback_service.dart';

class PlayService {
  late final playbackService = PlaybackService(this);
  late final lyricService = LyricService(this);
  late final desktopLyricService = DesktopLyricService(this);

  PlayService._();

  static PlayService? _instance;
  static PlayService get instance {
    _instance ??= PlayService._();
    return _instance!;
  }

  Future<void> close() async {
    await playbackService.closeSmtc();
    desktopLyricService.killDesktopLyric();
  }
}