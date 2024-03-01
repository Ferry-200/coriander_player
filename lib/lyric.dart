import 'package:coriander_player/src/rust/api/tag_reader.dart';

class LyricLine {
  Duration time;
  String content;

  bool isBlank;
  Duration? length;

  LyricLine(
      {required this.time,
      required this.content,
      required this.isBlank,
      this.length});

  static LyricLine blankLine = LyricLine(
    time: Duration.zero,
    content: "",
    isBlank: true,
    length: Duration.zero,
  );

  @override
  String toString() {
    return {"time": time.toString(), "content": content}.toString();
  }

  /// line: [mm:ss.msmsms]content
  static LyricLine? fromLine(String line) {
    if (line.trim().isEmpty) {
      return null;
    }

    var lrcTimeString = line.substring(
      line.indexOf("[") + 1,
      line.indexOf("]"),
    );
    var content = line.substring(line.indexOf("]") + 1).trim();

    var timeList = lrcTimeString.split(":");
    int? minute;
    double? second;
    if (timeList.length == 2) {
      minute = int.tryParse(timeList[0]);
      second = double.tryParse(timeList[1]);
    }

    if (minute == null || second == null) {
      return null;
    }

    var inMilliseconds = ((minute * 60 + second) * 1000).toInt();

    return LyricLine(
      time: Duration(milliseconds: inMilliseconds),
      content: content,
      isBlank: content.isEmpty,
    );
  }
}

enum LyricSource {
  /// mp3: USLT frame
  /// flac: LYRICS comment
  embedded,
  lrc,
}

class Lyric {
  List<LyricLine> lines;

  LyricSource source;

  Lyric(this.lines, this.source);

  @override
  String toString() {
    return {"type": source, "lyric": lines}.toString();
  }

  /// 歌词一般是有序的
  /// 按照时间升序排序，保留原文和译文的顺序，需要使用稳定的排序算法
  /// 这里使用插入排序
  void _sort() {
    for (int i = 1; i < lines.length; i++) {
      var temp = lines[i];
      int j;
      for (j = i; j > 0 && lines[j - 1].time > temp.time; j--) {
        lines[j] = lines[j - 1];
      }
      lines[j] = temp;
    }
  }

  /// line_1 and line_2时间戳相同，合并成line_1[separator]line_2
  Lyric _combineLyricLine(String separator) {
    _sort();
    List<LyricLine> combinedLines = [];
    var buf = StringBuffer();
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].time != lines[i - 1].time) {
        buf.write(lines[i - 1].content);
        combinedLines.add(LyricLine(
          time: lines[i - 1].time,
          content: buf.toString(),
          isBlank: lines[i - 1].isBlank,
          length: lines[i - 1].length,
        ));
        buf.clear();
      } else {
        buf.write(lines[i - 1].content);
        buf.write(separator);
      }
    }
    buf.write(lines.last.content);
    combinedLines.add(LyricLine(
      time: lines.last.time,
      content: buf.toString(),
      isBlank: lines.last.isBlank,
      length: lines.last.length,
    ));

    return Lyric(combinedLines, source);
  }

  /// 如果separator为null，不合并歌词；否则，合并相同时间戳的歌词
  static Lyric _fromLrcStr(String lrc, LyricSource source,
      {String? separator}) {
    var lrcLines = lrc.split("\n");

    var lines = <LyricLine>[];
    for (int i = 0; i < lrcLines.length; i++) {
      var lyricLine = LyricLine.fromLine(lrcLines[i]);
      if (lyricLine == null) {
        continue;
      }
      lines.add(lyricLine);
    }

    for (var i = 0; i < lines.length - 1; i++) {
      lines[i].length = lines[i + 1].time - lines[i].time;
    }
    lines.last.length = Duration.zero;

    final result = Lyric(lines, source);

    if (separator == null) {
      return result;
    }

    return result._combineLyricLine(separator);
  }

  /// .mp3: parse from USLT frame
  /// .flac: parse from LYRICS comment
  /// other: parse from .lrc file content
  static Future<Lyric?> fromAudioPath(String path, {String? separator}) async {
    final suffix = path.split(".").last.toLowerCase();

    if (suffix == "mp3") {
      return loadLyricFromMp3(path: path).then((value) {
        if (value == null) {
          return null;
        }
        return Lyric._fromLrcStr(
          value,
          LyricSource.embedded,
          separator: separator,
        );
      });
    } else if (suffix == "flac") {
      return loadLyricFromFlac(path: path).then((value) {
        if (value == null) {
          return null;
        }
        return Lyric._fromLrcStr(
          value,
          LyricSource.embedded,
          separator: separator,
        );
      });
    } else {
      return loadLyricFromLrc(path: path).then((value) {
        if (value == null) {
          return null;
        }
        return Lyric._fromLrcStr(
          value,
          LyricSource.lrc,
          separator: separator,
        );
      });
    }
  }
}
