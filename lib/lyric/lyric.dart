abstract class Lyric {
  List<LyricLine> lines;

  Lyric(this.lines);
}

abstract class LyricLine {
  Duration start;

  LyricLine(this.start);
}

abstract class UnsyncLyricLine extends LyricLine {
  String content;

  UnsyncLyricLine(super.start, this.content);
}

abstract class SyncLyricLine extends LyricLine {
  Duration length;
  List<SyncLyricWord> words;
  late String content;
  String? translation;

  SyncLyricLine(super.start, this.length, this.words, [this.translation]) {
    final buffer = StringBuffer();
    for (final e in words) {
      buffer.write(e.content);
    }
    content = buffer.toString();
  }

  @override
  String toString() {
    return "[${start.inMilliseconds},${length.inMilliseconds}]$content";
  }
}

abstract class SyncLyricWord {
  Duration start;
  Duration length;
  String content;

  SyncLyricWord(this.start, this.length, this.content);

  @override
  String toString() {
    return "(${start.inMilliseconds},${length.inMilliseconds})$content";
  }
}
