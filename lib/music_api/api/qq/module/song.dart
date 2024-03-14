part of '../qq.dart';

/*
* 歌词
*/
Future<Answer> _songLyric(Map params, List<Cookie> cookie) {
  final data = {
    "nobase64": 1,
    "format": 'json',
    "musicid": params['songId'],
    "songmid": params['songMid'],
  };
  return _get(
    "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_yqq.fcg",
    params: data,
    cookie: cookie,
  );
}

/*
* 歌词2
*/
Future<Answer> _songLyricNew(Map params, List<Cookie> cookie) {
  final data = {
    "nobase64": 1, //是否base64显示
    "format": 'json',
    "musicid": params['songId'],
    "songmid": params['songMid'],
  };
  return _get(
    "https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg",
    params: data,
    cookie: cookie,
  );
}

Future<Answer> _songLyric3(Map params, List<Cookie> cookie) {
  final data = {
    "version": 15,
    "miniversion": '82',
    "lrctype": '4',
    "musicid": params['songId'],
    // "songmid": params['songMid'],
  };
  return _getString(
    "https://c.y.qq.com/qqmusic/fcgi-bin/lyric_download.fcg",
    params: data,
    cookie: cookie,
  ).then((value) {
    var data = value.data["data"].toString().replaceAll("<!--", "").replaceAll("-->", "").replaceAll("miniversion=\"1\"", "miniversion");

    var lrc = XmlDocument.parse(data);

    var content = lrc.findAllElements('content').firstOrNull?.innerText;

    String decompressedString = QrcDecoder.decode(content ?? "");

    var qrc = XmlDocument.parse(decompressedString);

    var cc = qrc.findAllElements('Lyric_1').firstOrNull?.attributes.firstWhere((p0) => p0.localName == 'LyricContent').value;

    var dd = {"lyric": cc};

    return Future.value(value.copy(data: dd));
  });
}