import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/spending_model.dart';

final spendingServiceProvider = Provider<SpendingService>((ref) {
  return SpendingService(ref.read(dioProvider));
});

class SpendingService {
  final Dio _dio;

  SpendingService(this._dio);

  Future<SpendingProfileResponse> getProfiles() async {
    final response = await _dio.get('/api/v1/spending-profiles');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '소비 프로필 조회에 실패했습니다');
    }
    return SpendingProfileResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<SpendingProfileResponse> saveProfiles(List<SpendingItem> items) async {
    final response = await _dio.put('/api/v1/spending-profiles', data: {
      'items': items.map((i) => i.toJson()).toList(),
    });
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '소비 프로필 저장에 실패했습니다');
    }
    return SpendingProfileResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<void> deleteProfiles() async {
    final response = await _dio.delete('/api/v1/spending-profiles');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '소비 프로필 초기화에 실패했습니다');
    }
  }
}
