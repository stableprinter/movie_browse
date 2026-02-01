import 'package:network_package/network_call.dart' as net;

import '../config/app_config.dart';

export 'package:network_package/network_call.dart'
    show NetworkException, NetworkResponse;
/// Dio-free interceptor that adds Bearer auth. Token comes from [AppConfig] when not passed.
class AuthInterceptor extends net.NetworkInterceptor {
  AuthInterceptor([String? token]) : _token = token ?? AppConfig.apiToken ?? '';

  final String _token;

  @override
  void onRequest(net.NetworkRequestContext context, void Function() next) {
    context.headers['Authorization'] = 'Bearer $_token';
    next();
  }
}

/// Dio-free interceptor that logs requests and responses.
class LoggingInterceptor extends net.NetworkInterceptor {
  @override
  void onRequest(net.NetworkRequestContext context, void Function() next) {
    // ignore: avoid_print
    print('→ ${context.method} ${context.uri}');
    next();
  }

  @override
  void onResponse(net.NetworkResponseContext context, void Function() next) {
    // ignore: avoid_print
    print('← ${context.statusCode} ${context.uri}');
    next();
  }

  @override
  void onError(net.NetworkErrorContext context, void Function() next) {
    // ignore: avoid_print
    print('✗ ${context.uri}: ${context.message}');
    next();
  }
}

/// API client backed by [net.ApiClient] with Bearer auth and logging.
/// [baseUrl], [token], and [userId] default to [AppConfig] when not passed.
class ApiClient {
  ApiClient({
    String? baseUrl,
    String? token,
    String? userId,
  })  : _baseUrl = baseUrl ?? AppConfig.baseUrl ?? '',
        _userId = userId ?? AppConfig.userId {
    _client = net.ApiClient(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      interceptors: [
        AuthInterceptor(token ?? AppConfig.apiToken),
        LoggingInterceptor(),
      ],
    );
  }

  final String _baseUrl;
  final String? _userId;
  late final net.ApiClient _client;

  String get baseUrl => _baseUrl;
  String? get userId => _userId;

  Future<net.NetworkResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      _client.get<T>(path,
          queryParameters: queryParameters, headers: headers);

  Future<net.NetworkResponse<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      _client.post<T>(path,
          data: data,
          queryParameters: queryParameters,
          headers: headers);

  Future<net.NetworkResponse<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      _client.put<T>(path,
          data: data,
          queryParameters: queryParameters,
          headers: headers);

  Future<net.NetworkResponse<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      _client.patch<T>(path,
          data: data,
          queryParameters: queryParameters,
          headers: headers);

  Future<net.NetworkResponse<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      _client.delete<T>(path,
          data: data,
          queryParameters: queryParameters,
          headers: headers);
}
