class Banner {
  Banner({this.format, this.url});

  Banner.fromJson(dynamic json) {
    format = json['format'];
    url = json['url'];
  }

  String? format;
  String? url;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['format'] = format;
    map['url'] = url;
    return map;
  }
}
