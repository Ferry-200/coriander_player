import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/utils.dart';
import 'package:coriander_player/hotkeys_helper.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';

class ThemePickerDialog extends StatefulWidget {
  const ThemePickerDialog({super.key});

  @override
  State<ThemePickerDialog> createState() => _ThemePickerDialogState();
}

class _ThemePickerDialogState extends State<ThemePickerDialog> {
  var selectedColor = Color(AppSettings.instance.defaultTheme);
  late final rgbHexTextEditingController = TextEditingController(
    text: selectedColor.toRGBHexString(),
  );

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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "主题选择器",
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Focus(
                onFocusChange: HotkeysHelper.onFocusChanges,
                child: TextField(
                  autofocus: true,
                  controller: rgbHexTextEditingController,
                  onChanged: (value) {
                    final c = fromRGBHexString(value);
                    if (c != null) {
                      setState(() {
                        selectedColor = c;
                      });
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: "Hex RGB",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              SizedBox(
                height: 400,
                child: ColorWheelPicker(
                  color: selectedColor,
                  onChanged: (color) {
                    setState(() {
                      selectedColor = color;
                    });
                    rgbHexTextEditingController.text = color.toRGBHexString();
                  },
                  onWheel: (isWheel) {},
                ),
              ),
              const SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 8.0),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, selectedColor);
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
