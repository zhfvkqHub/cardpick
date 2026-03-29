import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/models/card_model.dart';
import '../../shared/providers/card_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/utils/format_utils.dart';
import '../../shared/widgets/common_widgets.dart';

class CardListView extends ConsumerWidget {
  const CardListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(cardListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('카드'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, size: 22),
            tooltip: '로그아웃',
            onPressed: () =>
                ref.read(authTokenProvider.notifier).logout(),
          ),
        ],
      ),
      body: cardsAsync.when(
        loading: () => const LoadingOverlay(),
        error: (_, __) => ErrorView(
          message: '카드 목록을 불러오지 못했습니다',
          onRetry: () => ref.refresh(cardListProvider),
        ),
        data: (cards) => cards.isEmpty
            ? const EmptyStateView(
                message: '등록된 카드가 없습니다',
                icon: Icons.credit_card_off_rounded,
              )
            : RefreshIndicator(
                onRefresh: () async => ref.refresh(cardListProvider),
                color: AppColors.primary,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: cards.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _CardListItem(card: cards[i]),
                ),
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
    final companyColor = getCompanyColor(card.cardCompany);

    return Card(
      child: InkWell(
        onTap: () => context.push('/cards/${card.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Company color badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: companyColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Icon(
                    Icons.credit_card_rounded,
                    color: companyColor,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Card info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card.cardName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      card.cardCompany,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Annual fee
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    card.annualFee == 0
                        ? '무료'
                        : '${formatCurrency(card.annualFee)}원',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: card.annualFee == 0
                          ? AppColors.success
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '연회비',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
