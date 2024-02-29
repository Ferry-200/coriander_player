import 'package:coriander_player/audio_library.dart';
import 'package:flutter/foundation.dart';

enum SortBy {
  name("名字"),
  origin("默认");

  final String methodName;
  const SortBy(this.methodName);
}

enum ListOrder { ascending, decending }

class ArtistsPageController extends ChangeNotifier {
  List<Artist> artistCollection =
      AudioLibrary.instance.artistCollection.values.toList();

  ListOrder order = ListOrder.ascending;
  SortBy sortMethod = SortBy.origin;

  void toggleOrder() {
    artistCollection = artistCollection.reversed.toList();
    order = order == ListOrder.ascending
        ? ListOrder.decending
        : ListOrder.ascending;
    notifyListeners();
  }

  void sortByName() {
    switch (order) {
      case ListOrder.ascending:
        artistCollection.sort((a, b) => a.name.compareTo(b.name));
        break;
      case ListOrder.decending:
        artistCollection.sort((a, b) => b.name.compareTo(a.name));
        break;
    }
    sortMethod = SortBy.name;
    notifyListeners();
  }

  void sortByOrigin() {
    switch (order) {
      case ListOrder.ascending:
        artistCollection =
            AudioLibrary.instance.artistCollection.values.toList();
        break;
      case ListOrder.decending:
        artistCollection = AudioLibrary.instance.artistCollection.values
            .toList()
            .reversed
            .toList();
        break;
    }
    sortMethod = SortBy.origin;
    notifyListeners();
  }
}
