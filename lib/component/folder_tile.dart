import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({
    super.key,
    required this.path,
    required this.onDelete,
  });

  final String path;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  path,
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 16.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                color: scheme.error,
                icon: const Icon(Symbols.delete),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
