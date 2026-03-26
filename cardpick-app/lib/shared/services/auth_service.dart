import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/auth_model.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.read(dioProvider));
});

class AuthService {
  final Dio _dio;

  AuthService(this._dio);

  Future<UserResponse> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/v1/auth/signup', data: {
      'nickname': name,
      'email': email,
      'password': password,
    });
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '회원가입에 실패했습니다');
    }
    return UserResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<TokenResponse> login({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post('/api/v1/auth/login', data: {
      'email': email,
      'password': password,
    });
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '로그인에 실패했습니다');
    }
    return TokenResponse.fromJson(json['data'] as Map<String, dynamic>);
  }
}
