part of '../kugou.dart';

Future<Answer> _lrc(Map params, List<Cookie> cookie) {
  String hash = params["hash"];

  var data = {
    "keyword": "",
    "hash": hash,
    "timelength": 0,
    "srcappid": 2919,
    "clientver": 20000,
    "clienttime": DateTime.now().millisecondsSinceEpoch,
    "mid": DateTime.now().millisecondsSinceEpoch,
    "uuid": DateTime.now().millisecondsSinceEpoch,
    "dfid": "-",
  };

  var signature = signatureParams(data);

  data["signature"] = signature;
  print(signature);
  return _get(
    "https://m3ws.kugou.com/api/v1/krc/get_lyrics",
    params: data,
    cookie: cookie,
  );
}

Future<Answer> _krc(Map params, List<Cookie> cookie) {
//http://lyrics.kugou.com/search?ver=1&man=yes&client=pc&keyword=%s&hash=%s&timelength=%s
  String hash = params["hash"];

  var data = {
    "keyword": "",
    "ver": 1,
    "hash": hash,
    "man": "yes",
    "client": "pc",
    "timelength": 0,
  };

  return _get(
    "http://lyrics.kugou.com/search",
    params: data,
    cookie: cookie,
  ).then((value) {
    var data = value.data;
    var id = (data["candidates"] as List<dynamic>).firstOrNull["id"];
    var accesskey = (data["candidates"] as List<dynamic>).firstOrNull["accesskey"];

    print(id);
    print(accesskey);
    return _krcInfo({"id": id, "accesskey": accesskey}, cookie);
  });
}

Future<Answer> _krcInfo(Map params, List<Cookie> cookie) {
  String id = params["id"];
  String accesskey = params["accesskey"];
  var data = {
    "ver": 1,
    "client": "pc",
    "id": id,
    "accesskey": accesskey,
    "fmt": "krc",
    "charset": "utf8",
  };

  return _get(
    "http://lyrics.kugou.com/download",
    params: data,
    cookie: cookie,
  ).then((value) {
    var content = value.data["content"];
    String result = decodeKrc(content);

    var krc = {"lyric": result};

    return Future.value(value.copy(data: krc));
  });
}
