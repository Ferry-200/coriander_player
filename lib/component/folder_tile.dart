import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';

class FolderTile extends StatelessWidget {
  const FolderTile({super.key, 
    required this.path,
    required this.onDelete,
  });

  final String path;
  final void Function() onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.scheme.surface,
          border: Border.all(color: theme.scheme.outline),
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
                    color: theme.scheme.onSurface,
                    fontSize: 16.0,
                  ),
                ),
              ),
              IconButton(
                onPressed: onDelete,
                hoverColor: theme.scheme.error.withOpacity(0.08),
                highlightColor: theme.scheme.error.withOpacity(0.12),
                splashColor: theme.scheme.error.withOpacity(0.12),
                icon: Icon(
                  Symbols.delete,
                  color: theme.scheme.error,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}