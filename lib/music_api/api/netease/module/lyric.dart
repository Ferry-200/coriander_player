part of '../netease.dart';

// 歌词
Future<Answer> _lyric(Map params, List<Cookie> cookie) {
  cookie.add(Cookie("os", "pc"));

  final data = {
    'id': params['id'],
    'lv': -1,
    'kv': -1,
    'tv': -1,
  };
  return request(
    'POST',
    'https://music.163.com/api/song/lyric',
    data,
    crypto: Crypto.linuxApi,
    cookies: cookie,
    ua: 'pc',
  );
}
