import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:crypto/crypto.dart';
import '../../entity/music_entity.dart';
import '../../http/http_dio.dart';
import '../../utils/answer.dart';
import 'dart:io';

part 'module/music.dart';

part 'module/search.dart';

class KuGou {
  KuGou._();

  static Future<Answer> lrc({String? hash}) {
    return _lrc.call({"hash": hash}, []);
  }

  static Future<Answer> krc({String? hash}) {
    return _krc.call({"hash": hash}, []);
  }

  ///搜索单曲
  static Future<Answer> searchSong({String? keyword, int? page, int? size}) {
    return _searchSong.call({"keyword": keyword, "page": page, "size": size}, []);
  }
}

//请求
Future<Answer> _get(String path, {Map<String, dynamic>? params, List<Cookie> cookie = const []}) async {
  Map<String, String> header = {
    "user-agent": "Mozilla/5.0 (Linux; Android 10; SM-G981B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.162 Mobile Safari/537.36 Edg/110.0.0.0",
    "cookie": "kg_mid=13b99c4ecc49b8e85dde00e21160b008; kg_dfid=1JdAUM1MExVq2HbWdD1cveSL; kg_dfid_collect=d41d8cd98f00b204e9800998ecf8427e; musicwo17=kugou",
  };

  return HttpDio().get(path, params: params, headers: header).then((value) async {
    try {
      if (value?.statusCode == 200) {
        var cookies = value?.headers[HttpHeaders.setCookieHeader];
        var ans = const Answer(site: MusicSite.KuGou);
        if (cookies != null) {
          ans = ans.copy(cookie: cookies.map((str) => Cookie.fromSetCookieValue(str)).toList());
        }
        if (value?.data is Map) {
          ans = ans.copy(code: value?.statusCode, data: value?.data);
        } else {
          ans = ans.copy(code: value?.statusCode, data: json.decode(value?.data.toString() ?? "{}"));
        }
        return Future.value(ans);
      } else {
        return Future.value(Answer(site: MusicSite.KuGou, code: 500, data: {'code': value?.statusCode, 'msg': value}));
      }
    } catch (e) {
      // if (kDebugMode) {
      //   print(e);
      // }
      return Future.value(const Answer(site: MusicSite.KuGou, code: 500, data: {'code': 500, 'msg': "酷狗对象转换异常"}));
    }
  });
}

String signatureParams(Map<String, dynamic> params) {
  var data = params.entries.sortedBy((element) => element.key).map((e) => "${e.key}=${e.value}").join();

  const secret = "NVPh5oo715z5DIWAeQlhMDsWXXQV4hwt";
  return md5.convert(utf8.encode("$secret$data$secret")).toString().toUpperCase();
}

String decodeKrc(String krc) {
  List<int> encKey = [0x40, 0x47, 0x61, 0x77, 0x5e, 0x32, 0x74, 0x47, 0x51, 0x36, 0x31, 0x2d, 0xce, 0xd2, 0x6e, 0x69];

  List<int> contentBytes = base64Decode(krc).sublist(4);

  for (int i = 0; i < contentBytes.length; i++) {
    contentBytes[i] ^= encKey[i % 16];
  }
  List<int> decompressedBytes = zlib.decode(contentBytes);
  return utf8.decode(decompressedBytes);
}
