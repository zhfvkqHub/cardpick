import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recommendation_model.dart';
import '../services/recommendation_service.dart';

final recommendationProvider = StateNotifierProvider<RecommendationNotifier,
    AsyncValue<RecommendationResponse?>>((ref) {
  return RecommendationNotifier(ref.read(recommendationServiceProvider));
});

class RecommendationNotifier
    extends StateNotifier<AsyncValue<RecommendationResponse?>> {
  final RecommendationService _service;

  RecommendationNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> loadLatest() async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.getLatest();
      state = AsyncValue.data(result);
    } catch (e, st) {
      // 추천 결과 없음(404)은 정상 케이스
      if (e is DioException && e.response?.statusCode == 404) {
        state = const AsyncValue.data(null);
      } else {
        state = AsyncValue.error(e, st);
      }
    }
  }

  Future<void> recommend() async {
    state = const AsyncValue.loading();
    try {
      final result = await _service.recommend();
      state = AsyncValue.data(result);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
