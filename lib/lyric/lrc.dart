import 'package:coriander_player/src/rust/api/tag_reader.dart';

class LrcLine {
  Duration time;
  String content;

  bool isBlank;
  Duration? length;

  LrcLine(
      {required this.time,
      required this.content,
      required this.isBlank,
      this.length});

  static LrcLine blankLine = LrcLine(
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
  static LrcLine? fromLine(String line) {
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

    return LrcLine(
      time: Duration(milliseconds: inMilliseconds),
      content: content,
      isBlank: content.isEmpty,
    );
  }
}

enum LrcSource {
  /// mp3: USLT frame
  /// flac: LYRICS comment
  embedded("内嵌"),
  lrcFile("外挂");

  final String name;

  const LrcSource(this.name);
}

class Lrc {
  List<LrcLine> lines;

  LrcSource source;

  Lrc(this.lines, this.source);

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
  Lrc _combineLrcLine(String separator) {
    _sort();
    List<LrcLine> combinedLines = [];
    var buf = StringBuffer();
    for (var i = 1; i < lines.length; i++) {
      if (lines[i].time != lines[i - 1].time) {
        buf.write(lines[i - 1].content);
        combinedLines.add(LrcLine(
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
    if (lines.isNotEmpty) {
      buf.write(lines.last.content);
      combinedLines.add(LrcLine(
        time: lines.last.time,
        content: buf.toString(),
        isBlank: lines.last.isBlank,
        length: lines.last.length,
      ));
    }

    return Lrc(combinedLines, source);
  }

  /// 如果separator为null，不合并歌词；否则，合并相同时间戳的歌词
  static Lrc _fromLrcStr(String lrc, LrcSource source,
      {String? separator}) {
    var lrcLines = lrc.split("\n");

    var lines = <LrcLine>[];
    for (int i = 0; i < lrcLines.length; i++) {
      var lyricLine = LrcLine.fromLine(lrcLines[i]);
      if (lyricLine == null) {
        continue;
      }
      lines.add(lyricLine);
    }

    for (var i = 0; i < lines.length - 1; i++) {
      lines[i].length = lines[i + 1].time - lines[i].time;
    }
    if (lines.isNotEmpty) {
      lines.last.length = Duration.zero;
    }

    final result = Lrc(lines, source);

    if (separator == null) {
      return result;
    }

    return result._combineLrcLine(separator);
  }

  /// .mp3: parse from USLT frame
  /// .flac: parse from LYRICS comment
  /// other: parse from .lrc file content
  static Future<Lrc?> fromAudioPath(String path, {String? separator}) async {
    final suffix = path.split(".").last.toLowerCase();

    if (suffix == "mp3") {
      return _fromMp3(path, separator);
    } else if (suffix == "flac") {
      return _fromFlac(path, separator);
    } else {
      return _fromLrcFile(path, separator);
    }
  }

  static Future<Lrc?> _fromLrcFile(String path, String? separator) {
    return loadLyricFromLrc(path: path).then((value) {
      if (value == null) {
        return null;
      }
      return Lrc._fromLrcStr(
        value,
        LrcSource.lrcFile,
        separator: separator,
      );
    });
  }

  static Future<Lrc?> _fromFlac(String path, String? separator) {
    return loadLyricFromFlac(path: path).then((value) {
      if (value == null) {
        return _fromLrcFile(path, separator);
      }
      return Lrc._fromLrcStr(
        value,
        LrcSource.embedded,
        separator: separator,
      );
    });
  }

  static Future<Lrc?> _fromMp3(String path, String? separator) {
    return loadLyricFromMp3(path: path).then((value) {
      if (value == null) {
        return _fromLrcFile(path, separator);
      }
      return Lrc._fromLrcStr(
        value,
        LrcSource.embedded,
        separator: separator,
      );
    });
  }
}
