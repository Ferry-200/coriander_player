import '../dio/dio.dart';
import 'app_exceptions.dart';

/// 错误处理拦截器
class ErrorInterceptor extends Interceptor {
  @override
  Future onError(DioError err, ErrorInterceptorHandler handler) {
    // debugPrint('DioError===: ${err.toString()}');
    // error统一处理
    AppException appException = AppException.create(err);
    // 错误提示
    // debugPrint('DioError===: ${appException.toString()}');
    // handler.next(err);
    throw appException;
  }
}
