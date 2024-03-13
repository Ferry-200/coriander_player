import 'package:coriander_player/library/audio_library.dart';
import 'package:flutter/widgets.dart';

enum SortBy {
  title("标题"),
  artist("艺术家"),
  album("专辑"),
  created("创建时间"),
  modified("修改时间"),
  origin("默认");

  final String methodName;
  const SortBy(this.methodName);
}

enum ListOrder { ascending, decending }

class AudiosPageController with ChangeNotifier {
  /// 当前要展示的列表；也是选中歌曲播放时设定的播放列表
  List<Audio> list = List.from(AudioLibrary.instance.audioCollection);

  SortBy sortBy = SortBy.origin;
  ListOrder listOrder = ListOrder.ascending;

  void setSortMethod(SortBy method) {
    sortBy = method;
    _sortBy();
    notifyListeners();
  }

  void setListOrder(ListOrder order) {
    listOrder = order;
    list = list.reversed.toList();
    notifyListeners();
  }

  void _sortBy() {
    switch (sortBy) {
      case SortBy.title:
        _sortByTitle();
        break;
      case SortBy.artist:
        _sortByArtist();
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
        list.sort((a, b) => a.title.compareTo(b.title));
        break;
      case ListOrder.decending:
        list.sort((a, b) => b.title.compareTo(a.title));
        break;
    }
  }

  void _sortByArtist() {
    switch (listOrder) {
      case ListOrder.ascending:
        list.sort((a, b) => a.artist.compareTo(b.artist));
        break;
      case ListOrder.decending:
        list.sort((a, b) => b.artist.compareTo(a.artist));
        break;
    }
  }

  void _sortByAlbum() {
    switch (listOrder) {
      case ListOrder.ascending:
        list.sort((a, b) => a.album.compareTo(b.album));
        break;
      case ListOrder.decending:
        list.sort((a, b) => b.album.compareTo(a.album));
        break;
    }
  }

  void _sortByCreated() {
    switch (listOrder) {
      case ListOrder.ascending:
        list.sort((a, b) => a.created.compareTo(b.created));
        break;
      case ListOrder.decending:
        list.sort((a, b) => b.created.compareTo(a.created));
        break;
    }
  }

  void _sortByModified() {
    switch (listOrder) {
      case ListOrder.ascending:
        list.sort((a, b) => a.modified.compareTo(b.modified));
        break;
      case ListOrder.decending:
        list.sort((a, b) => b.modified.compareTo(a.modified));
        break;
    }
  }

  void _sortByOrigin() {
    list = List.from(AudioLibrary.instance.audioCollection);
    if (listOrder == ListOrder.decending) {
      list = list.reversed.toList();
    }
  }
}
