import 'dart:convert';
import 'dart:io';

import '../../utils/utils.dart';

import 'qrc_decode_helper.dart';

class QrcDecoder {
  static final List<int> KEY1 = "!@#)(NHLiuy*\$%^&".codeUnits;
  static final List<int> KEY2 = "123ZXC!@#)(*\$%^&".codeUnits;
  static final List<int> KEY3 = "!@#)(*\$%^&abcDEF".codeUnits;

  static void des(List<int> data, List<int> key, int len) {
    List<List<int>> schedule = List.generate(16, (_) => List<int>.filled(6, 0));
    QrcDecodeHelper.desKeySetup(key, schedule, QrcDecodeHelper.ENCRYPT);
    for (int i = 0; i < len; i += 8) {
      List<int> inData = data.sublist(i, i + 8);
      QrcDecodeHelper.desCrypt(inData, inData, schedule);
      for (int j = 0; j < inData.length; j++) {
        data[i + j] = inData[j];
      }
    }
  }

  static void ddes(List<int> data, List<int> key, int len) {
    List<List<int>> schedule = List.generate(16, (_) => List<int>.filled(6, 0));
    QrcDecodeHelper.desKeySetup(key, schedule, QrcDecodeHelper.DECRYPT);
    for (int i = 0; i < len; i += 8) {
      List<int> inData = data.sublist(i, i + 8);
      QrcDecodeHelper.desCrypt(inData, inData, schedule);
      for (int j = 0; j < inData.length; j++) {
        data[i + j] = inData[j];
      }
    }
  }

  static String decode(String hex) {
    try {
      List<int> data = hex.hexToUint8List;
      int dataLen = data.length;

      ddes(data, KEY1, dataLen);
      des(data, KEY2, dataLen);
      ddes(data, KEY3, dataLen);

      List<int> decompressedBytes = zlib.decode(data);
      String result = utf8.decode(decompressedBytes);
      return result;
    } catch (e) {
      return "";
    }
  }
}
