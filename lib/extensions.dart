// ignore_for_file: unnecessary_this

import 'dart:ui';

import 'package:pinyin/pinyin.dart';

extension StringHMMSS on Duration {
  /// Returns a string with hours, minutes, seconds,
  /// in the following format: H:MM:SS
  String toStringHMMSS() {
    return toString().split(".").first;
  }
}

/// 把 dec 表示成两位 hex
String _toHexString(int dec) {
  assert(dec >= 0 && dec <= 0xff);

  var hex = dec.toRadixString(16);
  if (hex.length == 1) hex = "0$hex";
  return hex;
}

extension RGBHexString on Color {
  String toRGBHexString() {
    final redHex = _toHexString(red);
    final greenHex = _toHexString(green);
    final blueHex = _toHexString(blue);

    return "#$redHex$greenHex$blueHex";
  }
}

/// [rgbHexStr] 必须是 #RRGGBB
Color? fromRGBHexString(String rgbHexStr) {
  if (rgbHexStr.startsWith("#") && rgbHexStr.length == 7) {
    return Color(0xff000000 + int.parse(rgbHexStr.substring(1), radix: 16));
  }

  return null;
}

extension PinyinCompare on String {
  String _getPinyin() {
    final splited = this.split("");
    final pinyinStrBuilder = StringBuffer();

    for (var c in splited) {
      if (ChineseHelper.isChinese(c)) {
        final pinyin = PinyinHelper.convertToPinyinArray(
          c,
          PinyinFormat.WITHOUT_TONE,
        ).firstOrNull;

        pinyinStrBuilder.write(pinyin ?? c);
      } else {
        pinyinStrBuilder.write(c);
      }
    }

    return pinyinStrBuilder.toString();
  }

  /// Compares this string to [other] with pinyin first, else use the ordering of the code units.
  ///
  /// Returns a negative value if `this` is ordered before `other`,
  /// a positive value if `this` is ordered after `other`,
  /// or zero if `this` and `other` are equivalent.
  int localeCompareTo(String other) {
    if (!ChineseHelper.containsChinese(this) &&
        !ChineseHelper.containsChinese(other)) {
      return this.compareTo(other);
    }

    final thisCmpStr = this._getPinyin();
    final otherCmpStr = other._getPinyin();

    return thisCmpStr.compareTo(otherCmpStr);
  }
}
