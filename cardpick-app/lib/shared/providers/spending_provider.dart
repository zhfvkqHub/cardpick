import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spending_model.dart';
import '../services/spending_service.dart';

final spendingProfileProvider = StateNotifierProvider<SpendingNotifier,
    AsyncValue<SpendingProfileResponse?>>((ref) {
  return SpendingNotifier(ref.read(spendingServiceProvider));
});

class SpendingNotifier
    extends StateNotifier<AsyncValue<SpendingProfileResponse?>> {
  final SpendingService _service;

  SpendingNotifier(this._service) : super(const AsyncValue.data(null));

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _service.getProfiles();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> save(List<SpendingItem> items) async {
    state = const AsyncValue.loading();
    try {
      final profile = await _service.saveProfiles(items);
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  Future<void> delete() async {
    try {
      await _service.deleteProfiles();
      state = const AsyncValue.data(SpendingProfileResponse(items: []));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
