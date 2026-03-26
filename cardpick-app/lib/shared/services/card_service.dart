import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/card_model.dart';

final cardServiceProvider = Provider<CardService>((ref) {
  return CardService(ref.read(dioProvider));
});

class CardService {
  final Dio _dio;

  CardService(this._dio);

  Future<List<CardResponse>> getActiveCards() async {
    final response = await _dio.get('/api/v1/cards');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '카드 목록 조회에 실패했습니다');
    }
    return (json['data'] as List)
        .map((c) => CardResponse.fromJson(c as Map<String, dynamic>))
        .toList();
  }

  Future<CardDetailResponse> getCardDetail(int id) async {
    final response = await _dio.get('/api/v1/cards/$id');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception((json['error'] as Map?)?['message'] ?? '카드 상세 조회에 실패했습니다');
    }
    return CardDetailResponse.fromJson(json['data'] as Map<String, dynamic>);
  }
}
