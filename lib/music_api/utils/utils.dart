import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';

bool toBoolean(val) {
  if (val == '') return val;
  return val == 'true' || val == '1';
}

int getPageSize(int total, int size, {int? currentTotal, int? maxTotal}) {
  if (maxTotal != null && total > maxTotal) {
    total = maxTotal;
  }
  //这里防止有一些total不准确的情况导致大量请求，比如实际总数60，total是500，currentTotal是当前页数量
  if (currentTotal != null && size - currentTotal > 10) {
    return 1;
  } else {
    var remainder = total % size;
    int num = total ~/ size;
    if (remainder != 0) {
      return num + 1;
    } else {
      return num;
    }
  }
}

String toParamsString(LinkedHashMap? params) {
  return params?.entries.map((e) => "${e.key}=${e.value}").join("&") ?? "";
}

//删除一些转义字符，这个主要用于qqMusic
String lyricFormat(String lyric) {
  return lyric
      .replaceAll("&#10;", "\n")
      .replaceAll("&#13;", "\r")
      .replaceAll("&#32;", " ")
      .replaceAll("&#39;", "'")
      .replaceAll("&#40;", "(")
      .replaceAll("&#41;", ")")
      .replaceAll("&#45;", "-")
      .replaceAll("&#46;", ".")
      .replaceAll("&#58;", ":")
      .replaceAll("&#64;", "@")
      .replaceAll("&#95;", "_")
      .replaceAll("&#124;", "|");
}

Map<String, String> paramsToMap(String params) {
  var map = <String, String>{};

  params.split("&").forEach((element) {
    var entity = element.split("=");
    if (entity.length > 1) {
      map[entity[0]] = entity[1];
    } else {
      map[entity[0]] = "";
    }
  });

  return map;
}

//分割数组
List<List> splitList(List list, int len) {
  var length = list.length; //列表数组数据总条数
  List<List> result = []; //结果集合
  int index = 1;
  //循环 构造固定长度列表数组
  while (true) {
    if (index * len < length) {
      List temp = list.skip((index - 1) * len).take(len).toList();
      result.add(temp);
      index++;
      continue;
    }
    List temp = list.skip((index - 1) * len).toList();
    result.add(temp);
    break;
  }
  return result;
}

String getRandom(int length) {
  const ch = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz';
  Random r = Random();
  return String.fromCharCodes(Iterable.generate(length, (_) => ch.codeUnitAt(r.nextInt(ch.length))));
}

extension Uint8ListExt on String {
  Uint8List get uint8List {
    var ss = Uint8List.fromList(codeUnits);
    return ss;
  }

  Uint8List get hexToUint8List {
    if (isEmpty == true) {
      return Uint8List.fromList([]);
    }
    var tmpHex = toUpperCase();

    var array = <int>[];

    var str = StringBuffer();
    for (int i = 0; i < length; i++) {
      str.write(tmpHex[i]);

      if (str.length == 2 || i == length - 1) {
        var num = int.parse(str.toString(), radix: 16);
        array.add(num);

        str.clear();
      }
    }

    return Uint8List.fromList(array);
  }
}

extension HexExt on Uint8List {
  String get hex {
    return map((e) => e.toRadixString(16).padLeft(2, '0')).join().toUpperCase();
  }

  String get str {
    return String.fromCharCodes(this);
  }
}

Uint8List? restoreQrc(String hexText) {
  if (hexText.length % 2 != 0) return null;

  final arrBuf = Uint8List(hexText.length ~/ 2);



  for (var i = 0; i < hexText.length; i += 2) {
    arrBuf[i ~/ 2] = int.parse(hexText.substring(i, i + 2), radix: 16);
  }

  return arrBuf;
}

