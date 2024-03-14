import 'dart:io';

import '../dio/dio.dart';


/// 自定义异常
class AppException implements Exception {
  final String? msg;
  final int? code;

  AppException([
    this.code,
    this.msg,
  ]);

  String toString() {
    return "$code :$msg";
  }

  factory AppException.create(DioError error) {
    switch (error.type) {
      case DioErrorType.cancel:
        return BadRequestException(-1, "请求取消");
      case DioErrorType.connectionTimeout:
        return BadRequestException(-1, "连接超时");
      case DioErrorType.sendTimeout:
        return BadRequestException(-1, "请求超时");
      case DioErrorType.receiveTimeout:
        return BadRequestException(-1, "响应超时");
      case DioErrorType.badResponse:
        try {
          int? errCode = error.response?.statusCode;
          // String errMsg = error.response.statusMessage;
          // return ErrorEntity(code: errCode, message: errMsg);
          switch (errCode) {
            case 400:
              return BadRequestException(errCode ?? -1, "请求语法错误");
            case 401:
              return UnauthorisedException(errCode ?? -1, "没有权限");
            case 403:
              return UnauthorisedException(errCode ?? -1, "服务器拒绝执行");
            case 404:
              return UnauthorisedException(errCode ?? -1, "请求地址不存在");
            case 405:
              return UnauthorisedException(errCode ?? -1, "请求方法被禁止");
            case 500:
              return UnauthorisedException(errCode ?? -1, "服务器内部错误");
            case 502:
              return UnauthorisedException(errCode ?? -1, "无效的请求");
            case 503:
              return UnauthorisedException(errCode ?? -1, "服务器异常");
            case 505:
              return UnauthorisedException(errCode ?? -1, "不支持HTTP协议请求");
            default:
              return AppException(errCode, error.response?.statusMessage);
          }
        } on Exception catch (_) {
          return AppException(-1, "未知错误");
        }
      case DioErrorType.unknown:
        if (error.error is FileSystemException) {
          return BadRequestException(-1, "文件读取错误，请检查权限");
        }
        if (error.message?.contains('Insecure HTTP is not allowed by platform')==true) {
          return BadRequestException(-1, "请使用HTTPS请求");
        } else if (error.error is SocketException) {
          return BadRequestException(-1, "无法连接服务器");
        } else {
          return BadRequestException(-1, "未知异常:${error.message}");
        }
      default:
        return AppException(-1, error.message);
    }
  }
}

/// 请求错误
class BadRequestException extends AppException {
  BadRequestException([int? code, String? message]) : super(code, message);
}

/// 未认证异常
class UnauthorisedException extends AppException {
  UnauthorisedException([int? code, String? message]) : super(code, message);
}
