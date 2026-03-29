import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/models/spending_model.dart';
import '../../shared/providers/spending_provider.dart';
import '../../shared/utils/format_utils.dart';
import '../../shared/widgets/common_widgets.dart';

class SpendingView extends ConsumerStatefulWidget {
  const SpendingView({super.key});

  @override
  ConsumerState<SpendingView> createState() => _SpendingViewState();
}

class _SpendingViewState extends ConsumerState<SpendingView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
        () => ref.read(spendingProfileProvider.notifier).load());
  }

  Future<void> _deleteProfiles() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('소비 프로필 초기화'),
        content: const Text('모든 소비 패턴이 삭제됩니다.\n계속하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref.read(spendingProfileProvider.notifier).delete();
      if (mounted) showSuccessSnackBar(context, '소비 프로필이 초기화됐습니다');
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final spendingAsync = ref.watch(spendingProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('소비 패턴'),
      ),
      body: spendingAsync.when(
        loading: () => const LoadingOverlay(),
        error: (_, __) => ErrorView(
          message: '소비 프로필을 불러오지 못했습니다',
          onRetry: () =>
              ref.read(spendingProfileProvider.notifier).load(),
        ),
        data: (profile) {
          final items = profile?.items ?? [];
          return items.isEmpty
              ? _EmptySpending(
                  onAdd: () => context.push('/spending/edit'))
              : _SpendingList(
                  items: items,
                  onEdit: () => context.push('/spending/edit'),
                  onDelete: _deleteProfiles,
                );
        },
      ),
    );
  }
}

class _EmptySpending extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptySpending({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 44,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '소비 패턴을 등록해주세요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '월별 소비 내역을 입력하면\n나에게 딱 맞는 카드를 추천해드려요',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('소비 패턴 등록'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpendingList extends StatelessWidget {
  final List<SpendingItem> items;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SpendingList({
    required this.items,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final total = items.fold<int>(0, (sum, i) => sum + i.monthlyAmount);

    return Column(
      children: [
        // Total spending summary card
        Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '월 총 소비액',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${formatCurrency(total)}원',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${items.length}개 카테고리',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // Category list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final item = items[i];
              final icon = getCategoryIcon(item.categoryGroup);
              final percentage =
                  total > 0 ? item.monthlyAmount / total : 0.0;

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon,
                            size: 20, color: AppColors.primary),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.categoryDisplayName != null
                                  ? '${item.categoryGroupDisplayName} > ${item.categoryDisplayName}'
                                  : item.categoryGroupDisplayName ??
                                      item.categoryGroup,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: percentage,
                                minHeight: 4,
                                backgroundColor:
                                    AppColors.primary.withValues(alpha: 0.06),
                                color: AppColors.primary.withValues(alpha: 0.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${formatCurrency(item.monthlyAmount)}원',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Action buttons
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(
              top: BorderSide(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  label: const Text('초기화'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(
                      color: AppColors.accent.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, size: 18),
                  label: const Text('수정하기'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
