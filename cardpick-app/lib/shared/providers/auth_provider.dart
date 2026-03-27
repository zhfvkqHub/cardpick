import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/token_storage.dart';
import '../models/auth_model.dart';
import '../services/auth_service.dart';

final authTokenProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<String?>>((ref) {
  return AuthNotifier(
    ref.read(tokenStorageProvider),
    ref.read(authServiceProvider),
  );
});

class AuthNotifier extends StateNotifier<AsyncValue<String?>> {
  final TokenStorage _tokenStorage;
  final AuthService _authService;

  AuthNotifier(this._tokenStorage, this._authService)
      : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    final token = await _tokenStorage.getToken();
    state = AsyncValue.data(token);
  }

  Future<void> login(String email, String password) async {
    try {
      final tokenResponse =
          await _authService.login(email: email, password: password);
      await _tokenStorage.saveToken(tokenResponse.accessToken);
      state = AsyncValue.data(tokenResponse.accessToken);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserResponse> signup(
      String name, String email, String password) async {
    return _authService.signup(name: name, email: email, password: password);
  }

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
    state = const AsyncValue.data(null);
  }
}
