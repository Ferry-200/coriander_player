part of '../qq.dart';

/*
 *搜索
 * type 0:单曲, 1:相关歌手,2:专辑,3:歌单,4:MV,7:歌词,8:用户
 */
Future<Answer> _search(Map params, List<Cookie> cookie) {
  final num = params['size'] ?? 10;
  final page = params['page'] ?? 1;

  final data = {
    "data": json.encode({
      "comm": {"mina": 1, "ct": 25},
      "req": {
        "method": "DoSearchForQQMusicMobile",
        "module": "music.search.SearchBrokerCgiServer",
        "param": {
          "search_type": params['type'] ?? 0,
          "query": params['keyWord'],
          "page_num": page,
          "num_per_page": num,
        }
      }
    })
  };
  return _get(
    "https://u.y.qq.com/cgi-bin/musicu.fcg",
    params: data,
    cookie: cookie,
  );
}
