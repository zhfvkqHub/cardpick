import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../models/category_model.dart';

final categoryServiceProvider = Provider<CategoryService>((ref) {
  return CategoryService(ref.read(dioProvider));
});

class CategoryService {
  final Dio _dio;

  CategoryService(this._dio);

  Future<CategoryResponse> getCategories() async {
    final response = await _dio.get('/api/v1/categories');
    final json = response.data as Map<String, dynamic>;
    if (!(json['success'] as bool)) {
      throw Exception(
          (json['error'] as Map?)?['message'] ?? '카테고리 목록 조회에 실패했습니다');
    }
    return CategoryResponse.fromJson(json['data'] as Map<String, dynamic>);
  }
}
