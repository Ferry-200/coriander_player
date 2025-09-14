import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:coriander_player/app_paths.dart';
import 'package:flutter/material.dart';

/// 跨平台工具类，提供平台特定的功能实现
class PlatformHelper {
  /// 根据当前平台获取BASS库的文件扩展名
  static String get bassLibraryExtension {
    if (Platform.isWindows) return 'dll';
    if (Platform.isMacOS) return 'dylib';
    if (Platform.isLinux) return 'so';
    throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
  }

  /// 根据当前平台获取BASS库的加载路径
  static String get bassLibraryPath {
    final exeDir = path.dirname(Platform.resolvedExecutable);
    final libDir = Platform.isMacOS
        ? path.join(exeDir, '..', 'Frameworks')
        : path.join(exeDir, 'BASS');
    return path.join(libDir, 'libbass.${bassLibraryExtension}');
  }

  /// 根据当前平台获取BASS WASAPI库的加载路径
  static String get bassWasapiLibraryPath {
    // WASAPI是Windows特有的API，在非Windows平台上返回null
    if (!Platform.isWindows) return '';

    final exeDir = path.dirname(Platform.resolvedExecutable);
    return path.join(exeDir, 'BASS', 'basswasapi.dll');
  }

  /// 检查系统是否支持WASAPI
  static bool supportsWasapi() {
    // WASAPI仅在Windows平台上可用
    return Platform.isWindows;
  }

  /// 标准化路径，处理平台特定的路径分隔符
  static String normalizePath(String filePath) {
    // 针对不同平台使用path库进行路径标准化
    return path.normalize(filePath);
  }

  /// 获取桌面歌词组件的路径
  static String getDesktopLyricPath() {
    if (Platform.isMacOS) {
      // 在macOS平台上，返回应用程序目录下的桌面歌词路径
      final exeDir = path.dirname(Platform.resolvedExecutable);
      // 假设桌面歌词组件位于Frameworks目录下
      return path.join(exeDir, '..', 'Frameworks', 'desktop_lyric');
    }

    // 其他平台返回空字符串或抛出异常
    return '';
  }

  /// 根据当前平台获取BASS插件的加载路径
  static List<String> get bassPluginPaths {
    final exeDir = path.dirname(Platform.resolvedExecutable);
    final libDir = Platform.isMacOS
        ? path.join(exeDir, '..', 'Frameworks')
        : path.join(exeDir, 'BASS');

    final extensions = {
      'ape': Platform.isWindows ? 'dll' : 'dylib',
      'dsd': Platform.isWindows ? 'dll' : 'dylib',
      'flac': Platform.isWindows ? 'dll' : 'dylib',
      'midi': Platform.isWindows ? 'dll' : 'dylib',
      'opus': Platform.isWindows ? 'dll' : 'dylib',
      'wv': Platform.isWindows ? 'dll' : 'dylib',
    };

    return extensions.entries.map((entry) {
      final prefix = Platform.isWindows ? '' : 'lib';
      final name = Platform.isWindows
          ? 'bass${entry.key}.${entry.value}'
          : '${prefix}bass${entry.key}.${entry.value}';
      return path.join(libDir, name);
    }).toList();
  }

  /// 判断当前平台是否支持WASAPI独占模式
  static bool get isWasapiSupported => Platform.isWindows;

  /// 根据当前平台获取桌面歌词可执行文件路径
  static String get desktopLyricExecutablePath {
    final exeDir = path.dirname(Platform.resolvedExecutable);
    final lyricDir = path.join(exeDir, 'desktop_lyric');

    if (Platform.isWindows) {
      return path.join(lyricDir, 'desktop_lyric.exe');
    } else if (Platform.isMacOS) {
      // 在macOS上，桌面歌词可能是一个.app包或者可执行文件
      // 这里假设是一个名为desktop_lyric的可执行文件
      return path.join(lyricDir, 'desktop_lyric');
    } else {
      return path.join(lyricDir, 'desktop_lyric');
    }
  }

  /// 获取适合当前平台的路径连接方式
  static String joinPaths(List<String> paths) {
    return path.joinAll(paths);
  }

  /// 获取适合当前平台的文件路径分隔符
  static String get pathSeparator => path.separator;

  /// 获取系统主题信息
  /// 在非Windows平台上返回默认主题
  static Map<String, dynamic> getSystemTheme() {
    // 这里返回默认主题，实际的主题获取逻辑应该在Rust层实现
    return {
      'fore': {'a': 255, 'r': 255, 'g': 255, 'b': 255},
      'accent': {'a': 255, 'r': 59, 'g': 130, 'b': 246}
    };
  }

  /// 获取系统主题模式（明亮/黑暗）
  static ThemeMode getSystemThemeMode() {
    // 默认返回跟随系统主题
    return ThemeMode.system;
  }

  /// 获取系统默认主题颜色
  static int getDefaultSystemThemeColor() {
    // 默认返回蓝色主题色
    return 0xFF3B82F6;
  }
}
