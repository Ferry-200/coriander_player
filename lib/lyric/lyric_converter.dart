import 'lyric.dart';
import 'lrc.dart';
import 'krc.dart';
import 'qrc.dart';

/// 歌词转换工具类，用于将Dart端的Lyric对象转换为LRC格式文本
class LyricConverter {
  /// 格式化时间戳为LRC格式 [mm:ss.ms]
  static String _formatTimestamp(Duration startTime) {
    final minutes = startTime.inMinutes;
    final seconds = startTime.inSeconds % 60;
    final milliseconds = startTime.inMilliseconds % 1000;

    return '[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(3, '0')}]';
  }

  /// 从Lyric对象生成LRC格式文本
  ///
  /// 用于writeLyricsToFile的lrcText参数
  /// 支持翻译：翻译会以独立行的形式追加，使用相同的时间戳
  static String generateLrcText(Lyric? lyric) {
    if (lyric == null) return '';

    final buffer = StringBuffer();

    for (final line in lyric.lines) {
      final Duration startTime;
      final String lineContent;
      final String? translation;

      if (line is UnsyncLyricLine) {
        startTime = line.start;
        lineContent = line.content;
        translation = null;
      } else if (line is SyncLyricLine) {
        startTime = line.start;
        lineContent = line.content;
        translation = line.translation;
      } else {
        continue;
      }

      // 跳过空内容的行
      if (lineContent.trim().isEmpty) continue;

      // 格式化时间标签并写入歌词
      final timestamp = _formatTimestamp(startTime);
      buffer.write(timestamp);
      buffer.write(lineContent);
      buffer.writeln();

      // 如果有翻译，添加独立的翻译行
      if (translation != null && translation.trim().isNotEmpty) {
        buffer.write(timestamp);
        buffer.write(translation);
        buffer.writeln();
      }
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
