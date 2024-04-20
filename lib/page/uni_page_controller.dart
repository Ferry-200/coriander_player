import 'package:flutter/widgets.dart';

typedef SortMethod<T> = void Function(List<T> list, SortOrder order);

class SortMethodDesc<T> {
  IconData icon;
  String name;
  SortMethod<T> method;

  SortMethodDesc({
    required this.icon,
    required this.name,
    required this.method,
  });
}

enum SortOrder { ascending, decending }

enum ContentView { list, table }

class UniPageController<T> with ChangeNotifier {
  List<T> contentList;
  SortMethodDesc<T>? sortBy;
  SortOrder sortOrder;
  ContentView contentView;

  UniPageController({
    required this.contentList,
    this.sortBy,
    required this.sortOrder,
    required this.contentView,
  }) {
    sortBy?.method(contentList, sortOrder);
    notifyListeners();
  }

  void setSortBy(SortMethodDesc<T> sortBy) {
    this.sortBy = sortBy;
    this.sortBy?.method(contentList, sortOrder);
    notifyListeners();
  }

  void setSortOrder(SortOrder sortOrder) {
    this.sortOrder = sortOrder;
    contentList = contentList.reversed.toList();
    notifyListeners();
  }

  void setContentView(ContentView contentView) {
    this.contentView = contentView;
    notifyListeners();
  }
}
