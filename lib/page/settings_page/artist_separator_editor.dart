import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/component/settings_tile.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:coriander_player/library/audio_library.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class ArtistSeparatorEditor extends StatelessWidget {
  const ArtistSeparatorEditor({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      description: "自定义艺术家分隔符",
      action: FilledButton.icon(
        icon: const Icon(Symbols.edit),
        label: const Text("管理艺术家分隔符"),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const _ArtistSeparatorEditDialog(),
          );
        },
      ),
    );
  }
}

class _ArtistSeparatorEditDialog extends StatefulWidget {
  const _ArtistSeparatorEditDialog();

  @override
  State<_ArtistSeparatorEditDialog> createState() =>
      __ArtistSeparatorEditDialogState();
}

class __ArtistSeparatorEditDialogState
    extends State<_ArtistSeparatorEditDialog> {
  final appSettings = AppSettings.instance;
  late List<String> separators = List.from(appSettings.artistSeparator);
  Map<String, Widget> children = {};
  final currEditController = TextEditingController();
  bool editing = false;

  void _addArtistSeparator() {
    if (currEditController.text.isEmpty) return;
    setState(
      () {
        children.remove("");
        children[currEditController.text] = ListTile(
          title: Text(currEditController.text),
          trailing: IconButton(
            onPressed: () {
              separators.remove(currEditController.text);
              setState(() {
                children.remove(currEditController.text);
              });
            },
            icon: const Icon(Symbols.remove),
          ),
        );
        editing = false;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    for (var item in separators) {
      children[item] = ListTile(
        title: Text(item),
        trailing: IconButton(
          onPressed: () {
            separators.remove(item);
            setState(() {
              children.remove(item);
            });
          },
          icon: const Icon(Symbols.remove),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Dialog(
      insetPadding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: SizedBox(
        width: 350.0,
        height: 350.0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "管理艺术家分隔符",
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(children: children.values.toList()),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        editing = true;
                        children[""] = ListTile(
                          title: Focus(
                            onFocusChange: HotkeysHelper.onFocusChanges,
                            child: TextField(
                              controller: currEditController,
                              autofocus: true,
                              decoration: InputDecoration(
                                suffixIcon: IconButton(
                                  onPressed: _addArtistSeparator,
                                  icon: const Icon(Symbols.done),
                                ),
                              ),
                              onSubmitted: (value) {
                                _addArtistSeparator();
                              },
                            ),
                          ),
                        );
                      });
                    },
                    child: const Text("新增"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: editing
                        ? null
                        : () async {
                            appSettings.artistSeparator =
                                children.keys.toList();
                            appSettings.artistSplitPattern =
                                appSettings.artistSeparator.join("|");
                            await appSettings.saveSettings();
                            await AudioLibrary.initFromIndex();
                            if (context.mounted) {
                              Navigator.pop(context);
                            }
                          },
                    child: const Text("确定"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
