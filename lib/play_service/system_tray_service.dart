import 'dart:io';

import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/utils.dart';
import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';
import 'package:window_manager/window_manager.dart';

/// 系统托盘服务
/// 提供最小化到托盘的功能
class SystemTrayService {
  static final SystemTrayService _instance = SystemTrayService._();
  static SystemTrayService get instance => _instance;

  final SystemTray _systemTray = SystemTray();
  final Menu _menu = Menu();
  bool _isInitialized = false;

  SystemTrayService._();

  /// 初始化系统托盘
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 获取应用图标路径
      final iconPath = await _getIconPath();

      // 初始化系统托盘
      await _systemTray.initSystemTray(
        title: "Coriander Player",
        iconPath: iconPath,
        isTemplateIcon: Platform.isMacOS,
      );

      // 创建托盘菜单
      await _menu.buildFrom([
        MenuItemLabel(
          label: '显示',
          onClicked: () async {
            await windowManager.show();
            await windowManager.focus();
          },
        ),
        MenuItemLabel(
          label: '播放/暂停',
          onClicked: () {
            PlayService.instance.toggle();
          },
        ),
        MenuItemLabel(
          label: '下一首',
          onClicked: () {
            PlayService.instance.next();
          },
        ),
        MenuItemLabel(
          label: '上一首',
          onClicked: () {
            PlayService.instance.previous();
          },
        ),
        MenuItemSeparator(),
        MenuItemLabel(
          label: '退出',
          onClicked: () async {
            await _quitApp();
          },
        ),
      ]);

      await _systemTray.setContextMenu(_menu);

      // 监听托盘点击事件（双击显示窗口）
      _systemTray.registerSystemTrayEventHandler((eventName) {
        if (eventName == 'click') {
          windowManager.show();
          windowManager.focus();
        }
      });

      _isInitialized = true;
    } catch (err, trace) {
      LOGGER.e(err, stackTrace: trace);
    }
  }

  /// 获取图标路径
  Future<String> _getIconPath() async {
    if (Platform.isWindows) {
      // Windows: 使用 .ico 文件
      final exePath = Platform.resolvedExecutable;
      final exeDir = exePath.substring(0, exePath.lastIndexOf('\\'));
      return '$exeDir\\data\\flutter_assets\\app_icon.ico';
    } else if (Platform.isMacOS) {
      // macOS: 使用 .icns 文件
      final exePath = Platform.resolvedExecutable;
      final exeDir = exePath.substring(0, exePath.lastIndexOf('/'));
      return '$exeDir/../Resources/AppIcon.icns';
    } else {
      // Linux: 使用 .png 文件
      final exePath = Platform.resolvedExecutable;
      final exeDir = exePath.substring(0, exePath.lastIndexOf('/'));
      return '$exeDir/data/flutter_assets/app_icon.ico';
    }
  }

  /// 更新托盘提示文本（显示当前播放信息）
  Future<void> updateTooltip(String tooltip) async {
    if (!_isInitialized) return;
    try {
      await _systemTray.setTitle(tooltip);
    } catch (err, trace) {
      LOGGER.e(err, stackTrace: trace);
    }
  }

  /// 退出应用
  Future<void> _quitApp() async {
    PlayService.instance.close();

    await savePlaylists();
    await saveLyricSources();
    await AppSettings.instance.saveSettings();
    await AppPreference.instance.save();

    await HotkeysHelper.unregisterAll();
    await windowManager.close();
  }

  /// 销毁系统托盘
  Future<void> dispose() async {
    if (!_isInitialized) return;
    try {
      await _systemTray.destroy();
      _isInitialized = false;
    } catch (err, trace) {
      LOGGER.e(err, stackTrace: trace);
    }
  }
}
