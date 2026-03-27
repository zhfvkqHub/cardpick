import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

final categoryProvider =
    FutureProvider<CategoryResponse>((ref) async {
  return ref.read(categoryServiceProvider).getCategories();
});
