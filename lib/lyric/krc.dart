import 'package:coriander_player/lyric/lyric.dart';

class Krc extends Lyric {
  Krc(super.lines);

  static Krc fromKrcText(String krc) {
    final List<KrcLine> lines = [];
    final splited = krc.split("\n");
    for (final item in splited) {
      final qrcLine = KrcLine.fromLine(item);

      if (qrcLine == null) continue;

      lines.add(qrcLine);
    }

    // 添加空白
    final List<KrcLine> fommatedLines = [];
    for (int i = 0; i < lines.length - 1; ++i) {
      fommatedLines.add(lines[i]);
      final transitionStart = lines[i].start + lines[i].length;
      final transitionLength = lines[i + 1].start - transitionStart;
      if (transitionLength > const Duration(seconds: 5)) {
        fommatedLines.add(KrcLine(transitionStart, transitionLength, []));
      }
    }
    final lastLine = lines.lastOrNull;
    if (lastLine != null) {
      fommatedLines.add(lastLine);
    }

    return Krc(fommatedLines);
  }

  @override
  String toString() {
    return (lines as List<SyncLyricLine>).toString();
  }
}

class KrcLine extends SyncLyricLine {
  KrcLine(super.start, super.length, super.words);

  static KrcLine? fromLine(String line) {
    final splitedLine = line.split("]");
    final from = splitedLine[0].indexOf("[") + 1;
    final splitedTime = splitedLine[0].substring(from).split(",");

    if (splitedTime.length != 2) return null;

    final Duration start = Duration(
      milliseconds: int.tryParse(splitedTime[0]) ?? 0,
    );
    final Duration length = Duration(
      milliseconds: int.tryParse(splitedTime[1]) ?? 0,
    );

    final splitedContent = splitedLine[1].split("<");
    final List<KrcWord> words = [];
    for (final item in splitedContent) {
      final qrcWord = KrcWord.fromWord(item, start);

      if (qrcWord == null) continue;

      words.add(qrcWord);
    }

    return KrcLine(start, length, words);
  }
}

class KrcWord extends SyncLyricWord {
  KrcWord(super.start, super.length, super.content);

  static KrcWord? fromWord(String word, Duration lineStart) {
    final splitedWord = word.split(">");
    if (splitedWord.length != 2) return null;

    final splitedTime = splitedWord[0].split(",");

    if (splitedTime.length < 2) return null;

    final Duration start = Duration(
          milliseconds: int.tryParse(splitedTime[0]) ?? 0,
        ) +
        lineStart;
    final Duration length = Duration(
      milliseconds: int.tryParse(splitedTime[1]) ?? 0,
    );

    return KrcWord(start, length, splitedWord[1]);
  }
}
