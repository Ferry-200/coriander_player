import 'dart:convert';
import 'dart:io';

import '../entity/music_entity.dart';

class Answer {
  final int code;
  final MusicSite site;
  final dynamic data;
  final String msg;
  final List<Cookie> cookie;

  const Answer({required this.site, this.code = 200, this.data = const {'code': 500, 'msg': 'server error'}, this.msg = "操作成功", this.cookie = const []});

  Answer copy({MusicSite? site, int? code, dynamic data, String? msg, List<Cookie>? cookie}) {
    return Answer(site: site??this.site, code: code ?? this.code, data: data ?? this.data, msg: msg ?? this.msg, cookie: cookie ?? this.cookie);
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['code'] = code;
    map['msg'] = msg;
    map['data'] = data;
    map['cookie'] = cookie;
    return map;
  }

  @override
  String toString() {
    return json.encode({
      "code": code,
      "msg": msg,
      "data": data,
    });
  }
}
