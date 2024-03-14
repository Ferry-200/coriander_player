part of '../netease.dart';
//搜索
Future<Answer> _search(Map params, List<Cookie> cookie) {
  final num = params['size'] ?? 20;
  final page = params['page'] ?? 1;
  final offset = (page - 1) * num;

  //搜索声音
  if (params["type"] == "2000") {
    final data = {
      'keyword': params['keyWord'],
      "scene": 'normal',
      'limit': num,
      'offset': offset,
    };
    return request(
      'POST',
      'https://music.163.com/api/search/voice/get',
      data,
      crypto: Crypto.weApi,
      cookies: cookie,
    );
  }

  final data = {
    's': params['keyWord'],
    // 1: 单曲, 10: 专辑, 100: 歌手, 1000: 歌单, 1002: 用户, 1004: MV, 1006: 歌词, 1009: 电台, 1014: 视频
    'type': params['type'] ?? 1,
    'limit': num,
    'offset': offset,
  };
  return request(
    'POST',
    'https://music.163.com/weapi/search/get',
    data,
    crypto: Crypto.weApi,
    cookies: cookie,
  );
}