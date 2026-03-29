import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  final tokenStorage = ref.read(tokenStorageProvider);
  final dio = Dio(BaseOptions(
    baseUrl: AppConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
    validateStatus: (status) => status != null && status < 500,
  ));
  dio.interceptors.add(_AuthInterceptor(tokenStorage));
  return dio;
});

class _AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  _AuthInterceptor(this._tokenStorage);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _tokenStorage.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // 401 응답 시 저장된 토큰 삭제 (다음 인증 체크에서 로그인으로 리다이렉트)
    if (response.statusCode == 401) {
      _tokenStorage.deleteToken();
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err);
  }
}
