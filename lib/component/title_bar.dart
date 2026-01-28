// ignore_for_file: camel_case_types

import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/horizontal_lyric_view.dart';
import 'package:coriander_player/component/responsive_builder.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (context, screenType) {
        switch (screenType) {
          case ScreenType.small:
            return const _TitleBar_Small();
          case ScreenType.medium:
            return const _TitleBar_Medium();
          case ScreenType.large:
            return const _TitleBar_Large();
        }
      },
    );
  }
}

class _TitleBar_Small extends StatelessWidget {
  const _TitleBar_Small();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 56.0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            const _OpenDrawerBtn(),
            const SizedBox(width: 8.0),
            const NavBackBtn(),
            Expanded(
              child: DragToMoveArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "Coriander Player",
                    style: TextStyle(color: scheme.onSurface, fontSize: 16),
                  ),
                ),
              ),
            ),
            const WindowControlls(),
          ],
        ),
      ),
    );
  }
}

class _TitleBar_Medium extends StatelessWidget {
  const _TitleBar_Medium();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        const SizedBox(
          width: 80,
          child: Center(child: NavBackBtn()),
        ),
        Expanded(
          child: DragToMoveArea(
            child: Row(
              children: [
                Text(
                  "Coriander Player",
                  style: TextStyle(color: scheme.onSurface, fontSize: 16),
                ),
                const Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: HorizontalLyricView(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const WindowControlls(),
        const SizedBox(width: 8.0),
      ],
    );
  }
}

class _TitleBar_Large extends StatelessWidget {
  const _TitleBar_Large();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          const NavBackBtn(),
          const SizedBox(width: 8.0),
          Expanded(
            child: DragToMoveArea(
              child: Row(
                children: [
                  SizedBox(
                    width: 248,
                    child: Row(
                      children: [
                        Image.asset("app_icon.ico", width: 24, height: 24),
                        const SizedBox(width: 8.0),
                        Text(
                          "Coriander Player",
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(0, 8.0, 16.0, 8.0),
                      child: HorizontalLyricView(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const WindowControlls(),
        ],
      ),
    );
  }
}

class _OpenDrawerBtn extends StatelessWidget {
  const _OpenDrawerBtn();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "打开导航栏",
      onPressed: Scaffold.of(context).openDrawer,
      icon: const Icon(Symbols.side_navigation),
    );
  }
}

class NavBackBtn extends StatelessWidget {
  const NavBackBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: "返回",
      onPressed: () {
        if (context.canPop()) {
          context.pop();
        }
      },
      icon: const Icon(Symbols.navigate_before),
    );
  }
}

class WindowControlls extends StatefulWidget {
  const WindowControlls({super.key});

  @override
  State<WindowControlls> createState() => _WindowControllsState();
}

class _WindowControllsState extends State<WindowControlls> with WindowListener {
  bool _isFullScreen = false;
  bool _isMaximized = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
    _updateWindowStates();
  }

  Future<void> _updateWindowStates() async {
    final isFullScreen = await windowManager.isFullScreen();
    final isMaximized = await windowManager.isMaximized();
    if (mounted) {
      setState(() {
        _isFullScreen = isFullScreen;
        _isMaximized = isMaximized;
        _isProcessing = false;
      });
    }
  }

  Future<void> _toggleFullScreen() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await windowManager.setFullScreen(!_isFullScreen);
    } catch (e) {
      rethrow;
    } finally {
      // 无论成功还是失败，最终都重置处理状态
      // 调用_updateWindowStates()确保状态同步，即使监听器没有触发
      if (mounted) {
        await _updateWindowStates();
      }
    }
  }

  Future<void> _toggleMaximized() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      if (_isMaximized) {
        await windowManager.unmaximize();
      } else {
        await windowManager.maximize();
      }
    } catch (e) {
      rethrow;
    } finally {
      // 无论成功还是失败，最终都重置处理状态
      // 调用_updateWindowStates()确保状态同步，即使监听器没有触发
      if (mounted) {
        await _updateWindowStates();
      }
    }
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    _updateWindowStates();
    // 窗口最大化时保存设置
    AppSettings.instance.saveSettings();
  }

  @override
  void onWindowUnmaximize() {
    _updateWindowStates();
    // 窗口还原时保存设置
    AppSettings.instance.saveSettings();
  }

  @override
  void onWindowRestore() {
    _updateWindowStates();
    // 窗口从最小化恢复时保存设置
    AppSettings.instance.saveSettings();
  }

  @override
  void onWindowEnterFullScreen() {
    super.onWindowEnterFullScreen();
    _updateWindowStates();
    // 进入全屏时保存设置
    AppSettings.instance.saveSettings();
  }

  @override
  void onWindowLeaveFullScreen() {
    super.onWindowLeaveFullScreen();
    _updateWindowStates();
    // 退出全屏时保存设置
    AppSettings.instance.saveSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        IconButton(
          tooltip: _isFullScreen ? "退出全屏" : "全屏",
          onPressed: _isProcessing ? null : _toggleFullScreen,
          icon: Icon(
            _isFullScreen ? Symbols.close_fullscreen : Symbols.open_in_full,
          ),
        ),
        IconButton(
          tooltip: "最小化",
          onPressed: windowManager.minimize,
          icon: const Icon(Symbols.remove),
        ),
        IconButton(
          tooltip: _isFullScreen ? "全屏模式下不可用" : (_isMaximized ? "还原" : "最大化"),
          onPressed: _isFullScreen || _isProcessing ? null : _toggleMaximized,
          icon: Icon(
            _isMaximized ? Symbols.fullscreen_exit : Symbols.fullscreen,
          ),
        ),
        IconButton(
          tooltip: AppSettings.instance.minimizeToTray ? "最小化到托盘" : "退出",
          onPressed: () async {
            // 窗口关闭事件由 WindowHandler 统一处理
            await windowManager.close();
          },
          icon: const Icon(Symbols.close),
        ),
      ],
    );
  }
}
