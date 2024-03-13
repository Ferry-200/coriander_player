import 'package:coriander_player/library/audio_library.dart';
import 'package:flutter/foundation.dart';

enum SortBy {
  title("标题"),
  album("专辑"),
  created("创建时间"),
  modified("修改时间"),
  origin("默认");

  final String methodName;
  const SortBy(this.methodName);
}

enum ListOrder { ascending, decending }

class ArtistDetailPageController with ChangeNotifier {
  final Artist _artist;

  /// 当前要展示的列表；也是选中歌曲播放时设定的播放列表
  List<Audio> works;

  List<Album> albums;

  ArtistDetailPageController(this._artist)
      : works = List.from(_artist.works),
        albums = _artist.albumsMap.values.toList();

  SortBy sortBy = SortBy.origin;
  ListOrder listOrder = ListOrder.ascending;

  void setSortMethod(SortBy method) {
    sortBy = method;
    _sortBy();
    notifyListeners();
  }

  void setListOrder(ListOrder order) {
    listOrder = order;
    works = works.reversed.toList();
    notifyListeners();
  }

  void _sortBy() {
    switch (sortBy) {
      case SortBy.title:
        _sortByTitle();
        break;
      case SortBy.album:
        _sortByAlbum();
        break;
      case SortBy.created:
        _sortByCreated();
        break;
      case SortBy.modified:
        _sortByModified();
        break;
      case SortBy.origin:
        _sortByOrigin();
        break;
    }
  }

  void _sortByTitle() {
    switch (listOrder) {
      case ListOrder.ascending:
        works.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ListOrder.decending:
        works.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
  }

  void _sortByAlbum() {
    switch (listOrder) {
      case ListOrder.ascending:
        works.sort((a, b) => a.album.compareTo(b.artist));
        break;
      case ListOrder.decending:
        works.sort((a, b) => b.album.compareTo(a.artist));
        break;
    }
  }

  void _sortByCreated() {
    switch (listOrder) {
      case ListOrder.ascending:
        works.sort((a, b) => a.created.compareTo(b.created));
        break;
      case ListOrder.decending:
        works.sort((a, b) => b.created.compareTo(a.created));
        break;
    }
  }

  void _sortByModified() {
    switch (listOrder) {
      case ListOrder.ascending:
        works.sort((a, b) => a.modified.compareTo(b.modified));
        break;
      case ListOrder.decending:
        works.sort((a, b) => b.modified.compareTo(a.modified));
        break;
    }
  }

  void _sortByOrigin() {
    works = List.from(_artist.works);
    if (listOrder == ListOrder.decending) {
      works = works.reversed.toList();
    }
  }
}
