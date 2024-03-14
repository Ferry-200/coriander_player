import 'dart:io';

import 'answer.dart';

typedef Api = Future<Answer> Function(Map query, List<Cookie> cookie);
