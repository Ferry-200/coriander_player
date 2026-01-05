import 'lyric.dart';
import 'lrc.dart';
import 'krc.dart';
import 'qrc.dart';

/// 歌词转换工具类，用于将Dart端的Lyric对象转换为LRC格式文本
class LyricConverter {
  /// 从Lyric对象生成LRC格式文本
  ///
  /// 用于writeLyricsToFile的lrcText参数
  static String generateLrcText(Lyric? lyric) {
    if (lyric == null) return '';

    final buffer = StringBuffer();

    for (final line in lyric.lines) {
      final Duration startTime;
      final String lineContent;

      if (line is UnsyncLyricLine) {
        startTime = line.start;
        lineContent = line.content;
      } else if (line is SyncLyricLine) {
        startTime = line.start;
        lineContent = line.content;
      } else {
        continue;
      }

      // LRC格式：[mm:ss.ms]歌词文本
      final minutes = startTime.inMinutes;
      final seconds = startTime.inSeconds % 60;
      final milliseconds = startTime.inMilliseconds % 1000;

      // 格式化时间标签：[mm:ss.ms]
      buffer.write('[');
      buffer.write(minutes.toString().padLeft(2, '0'));
      buffer.write(':');
      buffer.write(seconds.toString().padLeft(2, '0'));
      buffer.write('.');
      buffer.write(milliseconds.toString().padLeft(3, '0'));
      buffer.write(']');
      buffer.write(lineContent);
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// 检查歌词是否包含逐字时间戳（KRC/QRC格式）
  static bool hasWordLevelTimestamps(Lyric? lyric) {
    if (lyric == null) return false;

    return lyric is Krc || lyric is Qrc;
  }

  /// 获取歌词格式描述
  static String getFormatDescription(Lyric? lyric) {
    if (lyric == null) return '无歌词';

    if (lyric is Lrc) return 'LRC歌词';
    if (lyric is Krc) return 'KRC歌词（逐字）';
    if (lyric is Qrc) return 'QRC歌词（逐字）';

    return '未知格式';
  }
}
