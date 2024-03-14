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
    return Krc(lines);
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
      final qrcWord = KrcWord.fromWord(item);

      if (qrcWord == null) continue;
      
      words.add(qrcWord);
    }

    return KrcLine(start, length, words);
  }
}

class KrcWord extends SyncLyricWord {
  KrcWord(super.start, super.length, super.content);

  static KrcWord? fromWord(String word) {
    final splitedWord = word.split(">");
    if(splitedWord.length != 2) return null;
    
    final splitedTime = splitedWord[0].split(",");

    if (splitedTime.length < 2) return null;

    final Duration start = Duration(
      milliseconds: int.tryParse(splitedTime[0]) ?? 0,
    );
    final Duration length = Duration(
      milliseconds: int.tryParse(splitedTime[1]) ?? 0,
    );

    return KrcWord(start, length, splitedWord[1]);
  }
}
