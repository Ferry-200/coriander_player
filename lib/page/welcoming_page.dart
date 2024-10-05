import 'dart:async';
import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/build_index_state_view.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/app_paths.dart' as app_paths;
import 'package:filepicker_windows/filepicker_windows.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:window_manager/window_manager.dart';

class WelcomingPage extends StatelessWidget {
  const WelcomingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(48.0),
        child: _TitleBar(),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "你的音乐放在哪些文件夹呢？",
                style: TextStyle(
                  color: scheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              Text(
                "软件会扫描这些文件夹（包括所有子文件夹）下的音乐并建立索引。",
                style: TextStyle(color: scheme.onSurface),
              ),
              const SizedBox(height: 16),
              const FolderSelectorView(),
            ],
          ),
        ),
      ),
    );
  }
}

class FolderSelectorView extends StatefulWidget {
  const FolderSelectorView({super.key});

  @override
  State<FolderSelectorView> createState() => _FolderSelectorViewState();
}

class _FolderSelectorViewState extends State<FolderSelectorView> {
  bool selecting = true;
  final List<String> folders = [];
  final applicationSupportDirectory = getAppDataDir();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 400,
      height: 400,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: selecting
            ? folderSelector(scheme)
            : FutureBuilder(
                future: applicationSupportDirectory,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const Center(
                      child: Text("Fail to get app data dir."),
                    );
                  }

                  return BuildIndexStateView(
                    indexPath: snapshot.data!,
                    folders: folders,
                    whenIndexBuilt: () async {
                      await Future.wait([
                        AppSettings.instance.saveSettings(),
                        AudioLibrary.initFromIndex(),
                      ]);
                      if (context.mounted) {
                        context.go(app_paths.AUDIOS_PAGE);
                      }
                    },
                  );
                },
              ),
      ),
    );
  }

  Widget folderSelector(ColorScheme scheme) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            FilledButton(
              onPressed: () async {
                // final path = await pickSingleFolder();
                // if (path == null) return;
                final dirPicker = DirectoryPicker();
                dirPicker.title = "选择文件夹";

                final dir = dirPicker.getDirectory();
                if (dir == null) return;

                setState(() {
                  folders.add(dir.path);
                });
              },
              child: const Text("添加文件夹"),
            ),
            FilledButton(
              onPressed: () {
                setState(() {
                  selecting = false;
                });
              },
              child: const Text("扫描"),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Expanded(
          child: ListView.builder(
            itemCount: folders.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(folders[i]),
              trailing: IconButton(
                tooltip: "移除",
                onPressed: () {
                  setState(() {
                    folders.removeAt(i);
                  });
                },
                color: scheme.error,
                icon: const Icon(Symbols.delete),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TitleBar extends StatelessWidget {
  const _TitleBar();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DragToMoveArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Image.asset("app_icon.ico", width: 24, height: 24),
                  ),
                  Text(
                    "Coriander Player",
                    style: TextStyle(color: scheme.onSurface, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8.0),
            const _WindowControlls(),
          ],
        ),
      ),
    );
  }
}

class _WindowControlls extends StatefulWidget {
  const _WindowControlls();

  @override
  State<_WindowControlls> createState() => __WindowControllsState();
}

class __WindowControllsState extends State<_WindowControlls>
    with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  @override
  void onWindowRestore() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: [
        IconButton(
          tooltip: "最小化",
          onPressed: windowManager.minimize,
          icon: const Icon(Symbols.remove),
        ),
        FutureBuilder(
          future: windowManager.isMaximized(),
          builder: (context, snapshot) {
            final isMaximized = snapshot.data ?? false;
            return IconButton(
              tooltip: isMaximized ? "还原" : "最大化",
              onPressed: isMaximized
                  ? windowManager.unmaximize
                  : windowManager.maximize,
              icon: Icon(
                isMaximized ? Symbols.fullscreen_exit : Symbols.fullscreen,
              ),
            );
          },
        ),
        IconButton(
          tooltip: "退出",
          onPressed: windowManager.close,
          icon: const Icon(Symbols.close),
        ),
      ],
    );
  }
}
