import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _key = 'access_token';
  final FlutterSecureStorage _storage;

  TokenStorage() : _storage = const FlutterSecureStorage();

  Future<String?> getToken() => _storage.read(key: _key);
  Future<void> saveToken(String token) => _storage.write(key: _key, value: token);
  Future<void> deleteToken() => _storage.delete(key: _key);
}

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
