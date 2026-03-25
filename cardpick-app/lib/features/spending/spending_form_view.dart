import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../shared/models/spending_model.dart';
import '../../shared/providers/spending_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class SpendingFormView extends ConsumerStatefulWidget {
  const SpendingFormView({super.key});

  @override
  ConsumerState<SpendingFormView> createState() => _SpendingFormViewState();
}

class _SpendingFormViewState extends ConsumerState<SpendingFormView> {
  final List<_Entry> _entries = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final existing =
        ref.read(spendingProfileProvider).value?.items ?? [];
    if (existing.isNotEmpty) {
      _entries.addAll(existing.map((item) => _Entry(
            category: item.category,
            controller:
                TextEditingController(text: item.monthlyAmount.toString()),
          )));
    } else {
      _entries.add(_Entry(
        category: AppConstants.spendingCategories.first,
        controller: TextEditingController(),
      ));
    }
  }

  @override
  void dispose() {
    for (final e in _entries) {
      e.controller.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() => _entries.add(_Entry(
          category: AppConstants.spendingCategories.first,
          controller: TextEditingController(),
        )));
  }

  void _removeEntry(int index) {
    if (_entries.length == 1) return;
    setState(() {
      _entries[index].controller.dispose();
      _entries.removeAt(index);
    });
  }

  Future<void> _save() async {
    for (final e in _entries) {
      if (e.controller.text.isEmpty) {
        showErrorSnackBar(context, '${e.category} 금액을 입력하세요');
        return;
      }
      final amount = int.tryParse(e.controller.text);
      if (amount == null || amount <= 0) {
        showErrorSnackBar(context, '${e.category} 금액은 0보다 커야 합니다');
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final items = _entries
          .map((e) => SpendingItem(
                category: e.category,
                monthlyAmount: int.parse(e.controller.text),
              ))
          .toList();
      await ref.read(spendingProfileProvider.notifier).save(items);
      if (mounted) {
        showSuccessSnackBar(context, '소비 프로필이 저장됐습니다');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context, e.toString().replaceAll('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소비 패턴 등록/수정'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: const Text('저장'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _entries.length,
              itemBuilder: (_, i) => _EntryRow(
                entry: _entries[i],
                canRemove: _entries.length > 1,
                onRemove: () => _removeEntry(i),
                onCategoryChanged: (cat) =>
                    setState(() => _entries[i].category = cat),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _addEntry,
                  icon: const Icon(Icons.add),
                  label: const Text('카테고리 추가'),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child:
                              CircularProgressIndicator(strokeWidth: 2))
                      : const Text('저장'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Entry {
  String category;
  final TextEditingController controller;

  _Entry({required this.category, required this.controller});
}

class _EntryRow extends StatelessWidget {
  final _Entry entry;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<String> onCategoryChanged;

  const _EntryRow({
    required this.entry,
    required this.canRemove,
    required this.onRemove,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validCategory =
        AppConstants.spendingCategories.contains(entry.category)
            ? entry.category
            : AppConstants.spendingCategories.first;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: validCategory,
                decoration: const InputDecoration(
                    labelText: '카테고리', isDense: true),
                items: AppConstants.spendingCategories
                    .map((c) =>
                        DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCategoryChanged(v);
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextField(
                controller: entry.controller,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly
                ],
                decoration: const InputDecoration(
                  labelText: '월 소비액',
                  suffixText: '원',
                  isDense: true,
                ),
              ),
            ),
            if (canRemove) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red),
                onPressed: onRemove,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
