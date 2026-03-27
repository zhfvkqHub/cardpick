import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/spending_model.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/providers/spending_provider.dart';
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
        content: const Text('모든 소비 패턴이 삭제됩니다. 계속하시겠습니까?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('취소')),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child:
                const Text('삭제', style: TextStyle(color: Colors.red)),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: '로그아웃',
            onPressed: () =>
                ref.read(authTokenProvider.notifier).logout(),
          ),
        ],
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text('소비 패턴을 등록해주세요',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('소비 패턴 등록'),
          ),
        ],
      ),
    );
  }
}

class _SpendingList extends StatelessWidget {
  final List<SpendingItem> items;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _SpendingList(
      {required this.items,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final total =
        items.fold<int>(0, (sum, i) => sum + i.monthlyAmount);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('월 총 소비액',
                  style: Theme.of(context).textTheme.titleSmall),
              Text(
                '${_fmt(total)}원',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            itemBuilder: (_, i) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.category_outlined),
                title: Text(items[i].categoryDisplayName != null
                    ? '${items[i].categoryGroupDisplayName} > ${items[i].categoryDisplayName}'
                    : items[i].categoryGroupDisplayName ?? items[i].categoryGroup),
                trailing: Text(
                  '${_fmt(items[i].monthlyAmount)}원/월',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('초기화'),
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('수정'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _fmt(int v) => v
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
