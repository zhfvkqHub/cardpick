import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/card_model.dart';
import '../../shared/providers/card_provider.dart';
import '../../shared/widgets/common_widgets.dart';

class CardDetailView extends ConsumerWidget {
  final int cardId;

  const CardDetailView({super.key, required this.cardId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(cardDetailProvider(cardId));

    return Scaffold(
      appBar: AppBar(title: const Text('카드 상세')),
      body: cardAsync.when(
        loading: () => const LoadingOverlay(),
        error: (_, __) => const ErrorView(message: '카드 정보를 불러오지 못했습니다'),
        data: (card) => _CardDetailBody(card: card),
      ),
    );
  }
}

class _CardDetailBody extends StatelessWidget {
  final CardDetailResponse card;

  const _CardDetailBody({required this.card});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카드 기본 정보
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.cardName,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(card.cardCompany,
                      style: const TextStyle(color: Colors.grey)),
                  const Divider(height: 24),
                  _InfoRow(
                    '연회비',
                    card.annualFee == 0 ? '무료' : '${_fmt(card.annualFee)}원',
                  ),
                  if (card.minimumSpending != null)
                    _InfoRow('최소 이용금액',
                        '${_fmt(card.minimumSpending!)}원/월'),
                  _InfoRow('카드 타입', card.cardType),
                  if (card.description != null) ...[
                    const SizedBox(height: 8),
                    Text(card.description!,
                        style: const TextStyle(
                            color: Colors.grey, fontSize: 13)),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '혜택 (${card.benefits.length}개)',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (card.benefits.isEmpty)
            const EmptyStateView(message: '등록된 혜택이 없습니다')
          else
            ...card.benefits.map((b) => _BenefitCard(benefit: b)),
        ],
      ),
    );
  }

  String _fmt(int v) => v
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _BenefitCard extends StatelessWidget {
  final BenefitResponse benefit;

  const _BenefitCard({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(benefit.category,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${benefit.benefitRate}% ${benefit.benefitType}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (benefit.minimumAmount != null ||
                benefit.benefitLimit != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (benefit.minimumAmount != null)
                    Text(
                      '최소 ${_fmt(benefit.minimumAmount!)}원',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  if (benefit.minimumAmount != null &&
                      benefit.benefitLimit != null)
                    const Text(' · ',
                        style: TextStyle(color: Colors.grey)),
                  if (benefit.benefitLimit != null)
                    Text(
                      '월 최대 ${_fmt(benefit.benefitLimit!)}원',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ],
            if (benefit.description != null) ...[
              const SizedBox(height: 4),
              Text(
                benefit.description!,
                style:
                    const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fmt(int v) => v
      .toString()
      .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
