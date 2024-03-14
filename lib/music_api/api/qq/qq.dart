import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import '../../entity/music_entity.dart';
import '../../http/http_dio.dart';
import '../../utils/answer.dart';
import 'package:xml/xml.dart';

import '../../utils/utils.dart';
import 'qrc_decoder.dart';

part 'module/search.dart';
part 'module/song.dart';

class QQ {
  QQ._();

  ///搜索
  static Future<Answer> search({String? keyWord, int? type, int? page, int? size}) {
    return _search.call({"keyWord": keyWord, "type": type, "page": page, "size": size}, []);
  }

  ///歌词
  static Future<Answer> songLyric({String? songMid, int? songId}) {
    return _songLyricNew.call({"songMid": songMid, "songId": songId}, []);
  }

  ///歌词
  static Future<Answer> songLyric2({String? songMid, int? songId}) {
    return _songLyric.call({"songMid": songMid, "songId": songId}, []);
  }

  ///歌词
  static Future<Answer> songLyric3({String? songMid, int? songId}) {
    return _songLyric3.call({"songMid": songMid, "songId": songId}, []);
  }
}

Map<String, String> _buildHeader(String path, List<Cookie> cookies) {
  final headers = {
    "user-agent": "Mozilla/5.0 (Linux; U; Android 11.0.0; zh-cn; MI 11 Build/OPR1.170623.032) AppleWebKit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30",
    "cookie": cookies.join("; "),
  };

  if (path.contains('y.qq.com')) {
    headers['Referer'] = 'https://y.qq.com/';
  }
  return headers;
}

Future<Answer> _get(
  String path, {
  Map<String, dynamic> params = const {},
  List<Cookie> cookie = const [],
  Map<String, String> header = const {},
}) async {
  final options = _buildHeader(path, cookie);

  if (header.isNotEmpty) {
    options.addAll(header);
  }

  return HttpDio().get(path, params: params, headers: options).then((value) async {
    try {
      if (value?.statusCode == 200) {
        var cookies = value?.headers[HttpHeaders.setCookieHeader] ?? [];
        var ans = const Answer(site: MusicSite.QQ);
        ans = ans.copy(cookie: cookies.map((str) => Cookie.fromSetCookieValue(str)).toList());
        ans = ans.copy(code: value?.statusCode, data: json.decode(value?.data.toString() ?? "{}"));
        return Future.value(ans);
      } else {
        return Future.error(const Answer(site: MusicSite.QQ, code: 500, msg: "服务异常"));
      }
    } catch (e) {
      return Future.error(const Answer(site: MusicSite.QQ, code: 500, msg: "QQ对象转换异常"));
    }
  });
}

Future<Answer> _getImage(
  String path, {
  Map<String, dynamic> params = const {},
  List<Cookie> cookie = const [],
  Map<String, String> header = const {},
}) async {
  final options = _buildHeader(path, cookie);

  if (header.isNotEmpty) {
    options.addAll(header);
  }

  return HttpDio().img(path, params: params, headers: options).then((value) async {
    try {
      if (value?.statusCode == 200) {
        var cookies = value?.headers[HttpHeaders.setCookieHeader] ?? [];
        var ans = const Answer(site: MusicSite.QQ);
        ans = ans.copy(cookie: cookies.map((str) => Cookie.fromSetCookieValue(str)).toList());

        var content = base64.encode(value?.data);
        print("data:image/png;base64,$content");

        // print(cookies);

        var data = {"domain": "data:image/png;base64,", "qr": content, "qrsig": ans.cookie.where((element) => element.name == "qrsig").first.value};

        ans = ans.copy(code: value?.statusCode, data: data);
        return Future.value(ans);
      } else {
        return Future.error(const Answer(site: MusicSite.QQ, code: 500, msg: "服务异常"));
      }
    } catch (e) {
      print(e);
      return Future.error(const Answer(site: MusicSite.QQ, code: 500, msg: "QQ对象转换异常"));
    }
  });
}

Future<Answer> _getString(
  String path, {
  Map<String, dynamic> params = const {},
  List<Cookie> cookie = const [],
  Map<String, String> header = const {},
}) async {
  final options = _buildHeader(path, cookie);

  if (header.isNotEmpty) {
    options.addAll(header);
  }
  LinkedHashMap signStr = LinkedHashMap();

  params.forEach((key, value) {
    signStr[key] = value;
  });
  var url = "$path?${toParamsString(signStr)}";
  return HttpDio().get(url, headers: options).then((value) async {
    try {
      if (value?.statusCode == 200) {
        var cookies = value?.headers[HttpHeaders.setCookieHeader] ?? [];
        var ans = const Answer(site: MusicSite.QQ);
        ans = ans.copy(cookie: cookies.map((str) => Cookie.fromSetCookieValue(str)).toList());

        String? content = value?.data?.toString();

        // print(content);

        var data = {"data": content};

        ans = ans.copy(code: value?.statusCode, data: data);
        return Future.value(ans);
      } else {
        return Future.error(const Answer(site: MusicSite.QQ, code: 500, msg: "服务异常"));
      }
    } catch (e) {
      print(e);
      return Future.error(const Answer(site: MusicSite.QQ, code: 500, msg: "QQ对象转换异常"));
    }
  });
}
