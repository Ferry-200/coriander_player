import 'package:coriander_player/app_settings.dart';
import 'package:coriander_player/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:github/github.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class CheckForUpdate extends StatefulWidget {
  const CheckForUpdate({super.key});

  @override
  State<CheckForUpdate> createState() => _CheckForUpdateState();
}

class _CheckForUpdateState extends State<CheckForUpdate> {
  bool isChecking = false;
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    final List<Widget> children = [
      FilledButton.icon(
        icon: const Icon(Symbols.update),
        label: const Text("检查更新"),
        onPressed: isChecking
            ? null
            : () async {
                setState(() {
                  isChecking = true;
                });

                final newest = await AppSettings.github.repositories
                    .listReleases(
                        RepositorySlug("Ferry-200", "coriander_player"))
                    .first;
                final newestVer = int.tryParse(
                      newest.tagName?.substring(1).replaceAll(".", "") ?? "",
                    ) ??
                    0;
                final currVer =
                    int.tryParse(AppSettings.version.replaceAll(".", "")) ?? 0;
                if (newestVer > currVer) {
                  if (context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => NewestUpdateView(release: newest),
                    );
                  }
                } else {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                        "无新版本",
                        style: TextStyle(color: theme.palette.onSecondary),
                      ),
                      backgroundColor: theme.palette.secondary,
                    ));
                  }
                }

                setState(() {
                  isChecking = false;
                });
              },
        style: theme.primaryButtonStyle,
      ),
    ];
    if (isChecking) {
      children.add(const SizedBox(width: 16.0));
      children.add(SizedBox(
        width: 16.0,
        height: 16.0,
        child: CircularProgressIndicator(
          color: theme.palette.primary,
          backgroundColor: theme.palette.primaryContainer,
        ),
      ));
    }
    return Material(
      type: MaterialType.transparency,
      child: Row(
        children: children,
      ),
    );
  }
}

class NewestUpdateView extends StatelessWidget {
  const NewestUpdateView({
    super.key,
    required this.release,
  });

  final Release release;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final textButtonStyle = ButtonStyle(
      overlayColor: MaterialStatePropertyAll(
        theme.palette.onSurface.withOpacity(0.08),
      ),
      foregroundColor: MaterialStatePropertyAll(theme.palette.onSurface),
    );
    final onSurface = TextStyle(color: theme.palette.onSurface);
    final onSurfaceVariant = TextStyle(color: theme.palette.onSurfaceVariant);
    final primary = TextStyle(
      color: theme.palette.primary,
      decoration: TextDecoration.underline,
      decorationColor: theme.palette.primary,
    );
    return Dialog(
      backgroundColor: theme.palette.surface,
      surfaceTintColor: theme.palette.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    release.name ?? "新版本",
                    style: TextStyle(
                      color: theme.palette.onSurface,
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Text(
                    "${release.tagName}\n${release.publishedAt}",
                    style: TextStyle(color: theme.palette.onSurface),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Markdown(
                data: release.body ?? "",
                onTapLink: (text, href, title) {
                  if (href != null) {
                    launchUrlString(href);
                  }
                },
                padding: EdgeInsets.zero,
                styleSheet: MarkdownStyleSheet(
                  a: primary,
                  p: onSurface,
                  code: onSurfaceVariant,
                  h1: onSurface,
                  h2: onSurface,
                  h3: onSurface,
                  h4: onSurface,
                  h5: onSurface,
                  h6: onSurface,
                  em: onSurface,
                  strong: onSurface,
                  del: onSurfaceVariant,
                  blockquote: onSurfaceVariant,
                  img: onSurface,
                  checkbox: onSurface,
                  listBullet: onSurface,
                  tableHead: onSurface,
                  tableBody: onSurface,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: textButtonStyle,
                    child: const Text("取消"),
                  ),
                  const SizedBox(width: 16.0),
                  TextButton.icon(
                    onPressed: () {
                      if (release.htmlUrl != null) {
                        launchUrlString(release.htmlUrl!);
                      }

                      Navigator.pop(context);
                    },
                    style: textButtonStyle,
                    icon: const Icon(Symbols.arrow_outward),
                    label: const Text("获取更新"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
