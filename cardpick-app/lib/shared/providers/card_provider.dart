import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../services/card_service.dart';

final cardListProvider = FutureProvider<List<CardResponse>>((ref) async {
  return ref.read(cardServiceProvider).getActiveCards();
});

final cardDetailProvider =
    FutureProvider.family<CardDetailResponse, int>((ref, id) async {
  return ref.read(cardServiceProvider).getCardDetail(id);
});
