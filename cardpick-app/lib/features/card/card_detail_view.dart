import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../app/theme.dart';
import '../../shared/models/card_model.dart';
import '../../shared/providers/card_provider.dart';
import '../../shared/utils/format_utils.dart';
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
    final companyColor = getCompanyColor(card.cardCompany);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header with gradient
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  companyColor,
                  companyColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        card.cardCompany,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.credit_card_rounded,
                      color: Colors.white.withValues(alpha: 0.4),
                      size: 32,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  card.cardName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (card.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    card.description!,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.75),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      _CardHeaderInfo(
                        label: '연회비',
                        value: card.annualFee == 0
                            ? '무료'
                            : '${formatCurrency(card.annualFee)}원',
                      ),
                      Container(
                        width: 1,
                        height: 28,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      _CardHeaderInfo(
                        label: '카드 타입',
                        value: card.cardType,
                      ),
                      if (card.minimumSpending != null) ...[
                        Container(
                          width: 1,
                          height: 28,
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        _CardHeaderInfo(
                          label: '최소 이용',
                          value: '${formatCurrency(card.minimumSpending!)}원',
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          // Benefits section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '혜택',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${card.benefits.length}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (card.benefits.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: EmptyStateView(message: '등록된 혜택이 없습니다'),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              itemCount: card.benefits.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (_, i) =>
                  _BenefitCard(benefit: card.benefits[i]),
            ),
        ],
      ),
    );
  }
}

class _CardHeaderInfo extends StatelessWidget {
  final String label;
  final String value;

  const _CardHeaderInfo({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
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
    final categoryIcon = getCategoryIcon(benefit.categoryGroup);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    categoryIcon,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    benefit.categoryDisplayName != null
                        ? '${benefit.categoryGroupDisplayName} > ${benefit.categoryDisplayName}'
                        : benefit.categoryGroupDisplayName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${benefit.benefitRate}% ${benefit.benefitType}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
            if (benefit.minimumAmount != null ||
                benefit.benefitLimit != null) ...[
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Wrap(
                  spacing: 12,
                  children: [
                    if (benefit.minimumAmount != null)
                      _InfoChip(
                        icon: Icons.arrow_upward_rounded,
                        text: '최소 ${formatCurrency(benefit.minimumAmount!)}원',
                      ),
                    if (benefit.benefitLimit != null)
                      _InfoChip(
                        icon: Icons.block_rounded,
                        text:
                            '월 최대 ${formatCurrency(benefit.benefitLimit!)}원',
                      ),
                  ],
                ),
              ),
            ],
            if (benefit.description != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  benefit.description!,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.textHint),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textHint,
          ),
        ),
      ],
    );
  }
}
