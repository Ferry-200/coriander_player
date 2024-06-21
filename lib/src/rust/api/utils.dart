// This file is automatically generated, so please do not edit it.
// Generated by `flutter_rust_bridge`@ 2.0.0.

// ignore_for_file: invalid_use_of_internal_member, unused_import, unnecessary_import

import '../frb_generated.dart';
import 'package:flutter_rust_bridge/flutter_rust_bridge_for_generated.dart';

// These functions are ignored because they are not marked as `pub`: `_launch_in_browser`, `_pick_single_folder`, `_show_in_explorer`

/// path: 文件或文件夹的绝对路径。
/// 会打开父级目录并选择路径指向的项。
Future<bool> showInExplorer({required String path}) =>
    RustLib.instance.api.crateApiUtilsShowInExplorer(path: path);

Future<String?> pickSingleFolder() =>
    RustLib.instance.api.crateApiUtilsPickSingleFolder();

Future<bool> launchInBrowser({required String uri}) =>
    RustLib.instance.api.crateApiUtilsLaunchInBrowser(uri: uri);
