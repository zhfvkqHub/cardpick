import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/card_model.dart';
import '../../shared/providers/card_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class CardListView extends ConsumerWidget {
  const CardListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('카드 목록')),
      body: cardsAsync.when(
        loading: () => const LoadingOverlay(),
        error: (_, __) => ErrorView(
          message: '카드 목록을 불러오지 못했습니다',
          onRetry: () => ref.refresh(cardListProvider),
        ),
        data: (cards) => cards.isEmpty
            ? const EmptyStateView(
                message: '등록된 카드가 없습니다',
                icon: Icons.credit_card_off,
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: cards.length,
                itemBuilder: (_, i) => _CardListItem(card: cards[i]),
              ),
      ),
    );
  }
}

class _CardListItem extends StatelessWidget {
  final CardResponse card;

  const _CardListItem({required this.card});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(
            Icons.credit_card,
            color: Theme.of(context).colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          card.cardName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(card.cardCompany),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('연회비', style: Theme.of(context).textTheme.labelSmall),
            Text(
              card.annualFee == 0 ? '무료' : '${_fmt(card.annualFee)}원',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        onTap: () => context.push('/cards/${card.id}'),
      ),
    );
  }

  String _fmt(int amount) => amount
      .toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},');
}
