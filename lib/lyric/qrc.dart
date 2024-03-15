import 'package:coriander_player/lyric/lyric.dart';

class Qrc extends Lyric {
  Qrc(super.lines);

  static Qrc fromQrcText(String qrc) {
    final List<QrcLine> lines = [];
    final splited = qrc.split("\n");
    for (final item in splited) {
      final qrcLine = QrcLine.fromLine(item);

      if (qrcLine == null) continue;

      lines.add(qrcLine);
    }

    // 添加空白
    final List<QrcLine> fommatedLines = [];
    for (int i = 0; i < lines.length - 1; ++i) {
      fommatedLines.add(lines[i]);
      final transitionStart = lines[i].start + lines[i].length;
      final transitionLength = lines[i + 1].start - transitionStart;
      if (transitionLength > const Duration(seconds: 5)) {
        fommatedLines.add(QrcLine(transitionStart, transitionLength, []));
      }
    }
    final lastLine = lines.lastOrNull;
    if (lastLine != null) {
      fommatedLines.add(lastLine);
    }

    return Qrc(lines);
  }

  @override
  String toString() {
    return (lines as List<SyncLyricLine>).toString();
  }
}

class QrcLine extends SyncLyricLine {
  QrcLine(super.start, super.length, super.words);

  static QrcLine? fromLine(String line) {
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

    final splitedContent = splitedLine[1].split(")");
    final List<QrcWord> words = [];
    for (final item in splitedContent) {
      final qrcWord = QrcWord.fromWord(item);

      if (qrcWord == null) continue;
      
      words.add(qrcWord);
    }

    return QrcLine(start, length, words);
  }
}

class QrcWord extends SyncLyricWord {
  QrcWord(super.start, super.length, super.content);

  static QrcWord? fromWord(String word) {
    final splitedWord = word.split("(");
    if(splitedWord.length != 2) return null;
    
    final splitedTime = splitedWord[1].split(",");

    if (splitedTime.length != 2) return null;

    final Duration start = Duration(
      milliseconds: int.tryParse(splitedTime[0]) ?? 0,
    );
    final Duration length = Duration(
      milliseconds: int.tryParse(splitedTime[1]) ?? 0,
    );

    return QrcWord(start, length, splitedWord[0]);
  }
}