import 'dart:convert';

import 'package:coriander_player/lyric/lyric.dart';

class Krc extends Lyric {
  Krc(super.lines);

  static Krc fromKrcText(String krc) {
    final List<KrcLine> lines = [];
    String? languageFrame;

    final splited = krc.split("\n");
    for (final item in splited) {
      if (languageFrame == null) {
        final tag = item.substring(
          item.indexOf("[") + 1,
          item.indexOf("]"),
        );
        var splitedTag = tag.split(":");
        final tagName = splitedTag.firstOrNull;
        if (tagName?.contains("language") == true) {
          languageFrame = splitedTag[1];
        }
      }

      final krcLine = KrcLine.fromLine(item);

      if (krcLine == null) continue;

      lines.add(krcLine);
    }

    if (languageFrame != null) {
      final Map languageMap = json.decode(utf8.decode(base64.decode(languageFrame)));
      List trans = [];
      for (var item in languageMap["content"]) {
        if (item["type"] == 1) {
          final List transContent = item["lyricContent"];
          for (List transLine in transContent) {
            trans.add(transLine.first);
          }
        }
      }
      int linesIt = 0, transIt = 0;
      while ((linesIt < lines.length) || (transIt < trans.length)) {
        lines[linesIt].translation = trans[transIt];
        linesIt += 1;
        transIt += 1;
      }
    }

    // 添加空白
    final List<KrcLine> fommatedLines = [];
    final firstLine = lines.firstOrNull;
    if (firstLine != null && firstLine.start > const Duration(seconds: 5)) {
      fommatedLines.add(KrcLine(Duration.zero, firstLine.start, []));
    }
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
  KrcLine(super.start, super.length, super.words, [super.translation]);

  static KrcLine? fromLine(String line, [String? translation]) {
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

    return KrcLine(start, length, words, translation);
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
