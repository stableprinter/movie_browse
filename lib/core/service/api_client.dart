import 'package:dio/dio.dart';

import '../config/app_config.dart';

/// Dio-based API client with Bearer auth and logging interceptors.
/// Token and userId come from [AppConfig] when not passed (set from main.dart).
class ApiClient {
  ApiClient({
    String? baseUrl,
    String? token,
    String? userId,
  })  : _baseUrl = baseUrl ?? AppConfig.baseUrl ?? '',
        _token = token ?? AppConfig.apiToken ?? '',
        _userId = userId ?? AppConfig.userId ?? '' {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    )..interceptors.addAll([
        _AuthInterceptor(_token),
        _LoggingInterceptor(),
      ]);
  }

  final String _baseUrl;
  final String _token;
  final String? _userId;
  late final Dio _dio;

  Dio get dio => _dio;
  String? get userId => _userId;
}

class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._token);

  final String _token;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    options.headers['Authorization'] = 'Bearer $_token';
    handler.next(options);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('→ ${options.method} ${options.uri}');
    handler.next(options);
  }

  @override
  void onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    // ignore: avoid_print
    print('← ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('✗ ${err.type} ${err.requestOptions.uri}: ${err.message}');
    handler.next(err);
  }
}
