import 'package:coriander_player/app_preference.dart';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:coriander_player/library/playlist.dart';
import 'package:coriander_player/lyric/lyric_source.dart';
import 'package:coriander_player/play_service/play_service.dart';
import 'package:coriander_player/play_service/system_tray_service.dart';
import 'package:coriander_player/utils.dart';
import 'package:window_manager/window_manager.dart';

/// 窗口事件处理器
/// 处理窗口关闭事件，支持最小化到托盘
class WindowHandler with WindowListener {
  static final WindowHandler _instance = WindowHandler._();
  static WindowHandler get instance => _instance;

  WindowHandler._();

  @override
  void onWindowClose() async {
    // 如果启用了最小化到托盘，则隐藏窗口而不是关闭
    if (AppSettings.instance.minimizeToTray) {
      await windowManager.hide();
    } else {
      // 完全退出应用
      await _quitApp();
    }
  }

  Future<void> _quitApp() async {
    PlayService.instance.close();

    await savePlaylists();
    await saveLyricSources();
    await AppSettings.instance.saveSettings();
    await AppPreference.instance.save();

    await HotkeysHelper.unregisterAll();
    await SystemTrayService.instance.dispose();
    await windowManager.destroy();
  }

  void init() {
    windowManager.addListener(this);
  }

  void dispose() {
    windowManager.removeListener(this);
  }
}
