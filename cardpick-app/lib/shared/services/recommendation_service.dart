import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/recommendation_model.dart';

final recommendationServiceProvider = Provider<RecommendationService>((ref) {
  return RecommendationService(ref.read(dioProvider));
});

class RecommendationService {
  final Dio _dio;

  RecommendationService(this._dio);

  Future<RecommendationResponse> recommend() async {
    final response = await _dio.post('/api/v1/recommendations');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '추천 요청에 실패했습니다');
    }
    return RecommendationResponse.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<RecommendationResponse> getLatest() async {
    final response = await _dio.get('/api/v1/recommendations/latest');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '추천 결과 조회에 실패했습니다');
    }
    return RecommendationResponse.fromJson(json['data'] as Map<String, dynamic>);
  }
}
