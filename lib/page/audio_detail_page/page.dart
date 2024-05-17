import 'package:coriander_player/library/audio_library.dart';
import 'package:coriander_player/component/album_tile.dart';
import 'package:coriander_player/component/artist_tile.dart';
import 'package:coriander_player/lyric/lrc.dart';
import 'package:coriander_player/src/rust/api/utils.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

class AudioDetailPage extends StatelessWidget {
  const AudioDetailPage({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final artists = List.generate(
      audio.splitedArtists.length,
      (i) {
        return AudioLibrary.instance.artistCollection[audio.splitedArtists[i]]!;
      },
    );
    final album = AudioLibrary.instance.albumCollection[audio.album]!;
    const space = SizedBox(height: 16.0);
    final lyric = Lrc.fromAudioPath(audio, separator: "\n");

    final styleTitle = TextStyle(fontSize: 22, color: scheme.onSurface);
    final styleContent = TextStyle(fontSize: 16, color: scheme.onSurface);

    return Material(
      color: scheme.surface,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(8.0),
        bottomRight: Radius.circular(8.0),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 96.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
              crossAxisAlignment: WrapCrossAlignment.end,
              children: [
                FutureBuilder(
                  future: audio.mediumCover,
                  builder: (context, snapshot) {
                    if (snapshot.data == null) {
                      return Icon(
                        Symbols.broken_image,
                        color: scheme.onSurface,
                        size: 200,
                      );
                    }
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image(
                        image: snapshot.data!,
                        width: 200,
                        height: 200,
                      ),
                    );
                  },
                ),
                Text(audio.title, style: styleTitle),
              ],
            ),
            space,

            /// artists
            Text("艺术家", style: styleTitle),
            space,
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: List.generate(
                artists.length,
                (i) {
                  return SizedBox(
                    width: 300,
                    child: ArtistTile(artist: artists[i]),
                  );
                },
              ),
            ),
            space,

            /// album
            Text("专辑", style: styleTitle),
            space,
            AlbumTile(album: album),
            space,

            /// path
            Wrap(
              spacing: 8.0,
              children: [
                Text("路径", style: styleTitle),
                TextButton(
                  onPressed: () async {
                    final result = await showInExplorer(path: audio.path);

                    if (!result && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("打开失败")),
                      );
                    }
                  },
                  child: const Text("在文件资源管理器中显示"),
                )
              ],
            ),
            space,
            Text(audio.path, style: styleContent),
            space,

            /// modified
            Text("修改时间", style: styleTitle),
            space,
            Text(
              DateTime.fromMillisecondsSinceEpoch(
                audio.modified * 1000,
              ).toString(),
              style: styleContent,
            ),
            space,

            /// created
            Text("创建时间", style: styleTitle),
            space,
            Text(
              DateTime.fromMillisecondsSinceEpoch(
                audio.created * 1000,
              ).toString(),
              style: styleContent,
            ),
            space,

            /// lyric
            FutureBuilder(
              future: lyric,
              builder: (context, snapshot) {
                if (snapshot.data == null) return const SizedBox.shrink();

                return Text(
                  "歌词（${snapshot.data!.source.name}）",
                  style: styleTitle,
                );
              },
            ),
            space,
            SizedBox(
              height: 400,
              child: FutureBuilder(
                future: lyric,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox.shrink();
                  }

                  return ListView.builder(
                    itemCount: snapshot.data!.lines.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        title: Text(
                          snapshot.data!.lines[i].start.toString(),
                          style: styleContent,
                        ),
                        subtitle: Text(
                          (snapshot.data!.lines[i] as LrcLine).content,
                          style: styleContent,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
