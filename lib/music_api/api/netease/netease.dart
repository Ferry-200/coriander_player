import 'net_request.dart';
import '../../utils/answer.dart';
import 'dart:io';

part 'module/lyric.dart';

part 'module/search.dart';

class Netease {
  Netease._();

  static Future<Answer> search(
      {String? keyWord, int? type, int? page, int? size}) {
    return _search.call(
        {"keyWord": keyWord, "type": type, "page": page, "size": size}, []);
  }

  ///歌词
  static Future<Answer> lyric({String? id}) {
    return _lyric.call({"id": id}, []).then((value) {
      var lrc = value.data["lrc"]["lyric"];
      return value.copy(data: lrc);
    });
  }
}
