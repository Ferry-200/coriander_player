import 'package:coriander_player/audio_library.dart';
import 'package:flutter/foundation.dart';

enum SortBy {
  name("标题"),
  artist("艺术家"),
  origin("默认");

  final String methodName;
  const SortBy(this.methodName);
}

enum ListOrder { ascending, decending }

class AlbumsPageController extends ChangeNotifier {
  List<Album> albumCollection =
      AudioLibrary.instance.albumCollection.values.toList();

  ListOrder order = ListOrder.ascending;
  SortBy sortMethod = SortBy.origin;

  void toggleOrder() {
    albumCollection = albumCollection.reversed.toList();
    order = order == ListOrder.ascending
        ? ListOrder.decending
        : ListOrder.ascending;
    notifyListeners();
  }

  void sortByName() {
    switch (order) {
      case ListOrder.ascending:
        albumCollection.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ListOrder.decending:
        albumCollection.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    sortMethod = SortBy.name;
    notifyListeners();
  }

  void sortByArtist() {
    switch (order) {
      case ListOrder.ascending:
        albumCollection.sort(
          (a, b) => a.artistsMap.values.first.name.compareTo(
            b.artistsMap.values.first.name,
          ),
        );
        break;
      case ListOrder.decending:
        albumCollection.sort(
          (a, b) => b.artistsMap.values.first.name.compareTo(
            a.artistsMap.values.first.name,
          ),
        );
        break;
    }
    sortMethod = SortBy.artist;
    notifyListeners();
  }

  void sortByOrigin() {
    switch (order) {
      case ListOrder.ascending:
        albumCollection = AudioLibrary.instance.albumCollection.values.toList();
        break;
      case ListOrder.decending:
        albumCollection = AudioLibrary.instance.albumCollection.values
            .toList()
            .reversed
            .toList();
        break;
    }
    sortMethod = SortBy.origin;
    notifyListeners();
  }
}
