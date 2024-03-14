part of '../kugou.dart';

///搜索单曲
Future<Answer> _searchSong(Map params, List<Cookie> cookie) {
  return _get(
    "http://mobilecdnbj.kugou.com/api/v3/search/song",
    params: {
      "keyword": params["keyword"],
      "page": params["page"] ?? 1,
      "pagesize": params["size"] ?? 30,
    },
    cookie: cookie,
  );
}