import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/spending_model.dart';
import '../../shared/providers/category_provider.dart';
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
            categoryGroup: item.categoryGroup,
            category: item.category,
            controller:
                TextEditingController(text: item.monthlyAmount.toString()),
          )));
    } else {
      _entries.add(_Entry(
        categoryGroup: '',
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
          categoryGroup: '',
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
      if (e.categoryGroup.isEmpty) {
        showErrorSnackBar(context, '대분류를 선택하세요');
        return;
      }
      if (e.controller.text.isEmpty) {
        showErrorSnackBar(context, '금액을 입력하세요');
        return;
      }
      final amount = int.tryParse(e.controller.text);
      if (amount == null || amount <= 0) {
        showErrorSnackBar(context, '금액은 0보다 커야 합니다');
        return;
      }
    }

    final keys = _entries.map((e) => '${e.categoryGroup}:${e.category ?? ''}').toList();
    if (keys.length != keys.toSet().length) {
      showErrorSnackBar(context, '중복된 카테고리가 있습니다');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final items = _entries
          .map((e) => SpendingItem(
                categoryGroup: e.categoryGroup,
                category: e.category?.isNotEmpty == true ? e.category : null,
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
    final categoryAsync = ref.watch(categoryProvider);

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
      body: categoryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('카테고리 로딩 실패: $e')),
        data: (categoryData) => Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _entries.length,
                itemBuilder: (_, i) => _EntryRow(
                  entry: _entries[i],
                  categoryGroups: categoryData.groups,
                  canRemove: _entries.length > 1,
                  onRemove: () => _removeEntry(i),
                  onGroupChanged: (group) => setState(() {
                    _entries[i].categoryGroup = group;
                    _entries[i].category = null;
                  }),
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
      ),
    );
  }
}

class _Entry {
  String categoryGroup;
  String? category;
  final TextEditingController controller;

  _Entry({
    required this.categoryGroup,
    this.category,
    required this.controller,
  });
}

class _EntryRow extends StatelessWidget {
  final _Entry entry;
  final List<CategoryGroupDto> categoryGroups;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<String> onGroupChanged;
  final ValueChanged<String?> onCategoryChanged;

  const _EntryRow({
    required this.entry,
    required this.categoryGroups,
    required this.canRemove,
    required this.onRemove,
    required this.onGroupChanged,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    final validGroup = categoryGroups.any((g) => g.code == entry.categoryGroup)
        ? entry.categoryGroup
        : null;

    final subcategories = validGroup != null
        ? categoryGroups
            .firstWhere((g) => g.code == validGroup)
            .categories
        : <CategoryDto>[];

    final validCategory =
        subcategories.any((c) => c.code == entry.category)
            ? entry.category
            : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: validGroup,
                    decoration: const InputDecoration(
                        labelText: '대분류', isDense: true),
                    items: categoryGroups
                        .map((g) => DropdownMenuItem(
                            value: g.code, child: Text(g.displayName)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) onGroupChanged(v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String?>(
                    initialValue: validCategory,
                    decoration: const InputDecoration(
                        labelText: '소분류 (선택)', isDense: true),
                    items: [
                      const DropdownMenuItem<String?>(
                          value: null, child: Text('전체')),
                      ...subcategories.map((c) => DropdownMenuItem<String?>(
                          value: c.code, child: Text(c.displayName))),
                    ],
                    onChanged: (v) => onCategoryChanged(v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
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
          ],
        ),
      ),
    );
  }
}
