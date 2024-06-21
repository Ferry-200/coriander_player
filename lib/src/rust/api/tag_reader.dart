// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `_build_index_from_path`, `_get_picture_by_windows`, `_update_index_below_1_1_0`, `_update_index`, `new_with_path`, `read_by_lofty`, `read_by_win_music_properties`, `read_from_folder_recursively`, `read_from_folder`, `read_from_path`, `to_json_value`, `to_json_value`
// These types are ignored because they are not used by any `pub` functions: `AudioFolder`, `Audio`
// These function are ignored because they are on traits that is not defined in current crate (put an empty `#[frb]` on it to unignore): `fmt`, `fmt`

/// for Flutter
/// 如果无法通过 Lofty 获取则通过 Windows 获取
Future<Uint8List?> getPictureFromPath({required String path}) =>
    RustLib.instance.api.crateApiTagReaderGetPictureFromPath(path: path);

/// for Flutter
/// 只支持读取 ID3V2, VorbisComment, Mp4Ilst 存储的内嵌歌词
/// 以及相同目录相同文件名的 .lrc 外挂歌词（utf-8 or utf-16）
Future<String?> getLyricFromPath({required String path}) =>
    RustLib.instance.api.crateApiTagReaderGetLyricFromPath(path: path);

/// for Flutter
/// 扫描给定路径下所有子文件夹（包括自己）的音乐文件并把索引保存在 index_path/index.json。
/// true：成功；false：失败
Stream<IndexActionState> buildIndexFromPath(
        {required String path, required String indexPath}) =>
    RustLib.instance.api
        .crateApiTagReaderBuildIndexFromPath(path: path, indexPath: indexPath);

/// for Flutter
/// 读取 index_path/index.json，检查更新。不可能重新读取被修改的文件夹下所有的音乐标签，这样太耗时。
///
/// [LOWEST_VERSION] 指定可以继承的 index 的最低版本。
/// 如果 index version < [LOWEST_VERSION] 或者是 index 根本没有 version 再或者格式不符合要求，就转到
/// [_update_index_below_1_1_0] 更新 index；
/// 如果 index version >= [LOWEST_VERSION] 则进行更新。
///
/// 如果文件夹不存在，删除记录。
/// 如果文件夹被修改（再次读取到的 modified > 记录的 modified），就更新它。没有则跳过它
/// 1. 遍历该文件夹索引，判断文件是否存在，不存在则删除记录
/// 2. 遍历该文件夹索引，如果文件被修改（再次读取到的 modified > 记录的 modified），重新读取标签；没有则跳过它
/// 3. 遍历该文件夹，添加新增（读取到的 created > 记录的 latest）的音乐文件
Stream<IndexActionState> updateIndex({required String indexPath}) =>
    RustLib.instance.api.crateApiTagReaderUpdateIndex(indexPath: indexPath);

class IndexActionState {
  /// completed / total
  final double progress;

  /// describe action state
  final String message;

  const IndexActionState({
    required this.progress,
    required this.message,
  });

  @override
  int get hashCode => progress.hashCode ^ message.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IndexActionState &&
          runtimeType == other.runtimeType &&
          progress == other.progress &&
          message == other.message;
}
