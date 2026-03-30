import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/models/card_model.dart';
import '../../shared/providers/card_provider.dart';
import '../../shared/providers/auth_provider.dart';
import '../../shared/utils/format_utils.dart';
import '../../shared/widgets/common_widgets.dart';

class CardListView extends ConsumerStatefulWidget {
  const CardListView({super.key});

  @override
  ConsumerState<CardListView> createState() => _CardListViewState();
}

class _CardListViewState extends ConsumerState<CardListView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '전체'),
            Tab(text: '신용'),
            Tab(text: '체크'),
          ],
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w400,
            fontSize: 14,
          ),
        ),
      ),
      body: cardsAsync.when(
        loading: () => const LoadingOverlay(),
        error: (_, __) => ErrorView(
          message: '카드 목록을 불러오지 못했습니다',
          onRetry: () => ref.refresh(cardListProvider),
        ),
        data: (cards) => TabBarView(
          controller: _tabController,
          children: [
            _CardList(cards: cards),
            _CardList(cards: cards.where((c) => c.cardType == '신용').toList()),
            _CardList(cards: cards.where((c) => c.cardType == '체크').toList()),
          ],
        ),
      ),
    );
  }
}

class _CardList extends StatelessWidget {
  final List<CardResponse> cards;

  const _CardList({required this.cards});

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) {
      return const EmptyStateView(
        message: '해당하는 카드가 없습니다',
        icon: Icons.credit_card_off_rounded,
      );
    }
    return Consumer(
      builder: (context, ref, _) => RefreshIndicator(
        onRefresh: () async => ref.refresh(cardListProvider),
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          itemCount: cards.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
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
                    Row(
                      children: [
                        Text(
                          card.cardCompany,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        if (card.cardType.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: card.cardType == '신용'
                                  ? AppColors.primary.withValues(alpha: 0.1)
                                  : AppColors.success.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              card.cardType,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: card.cardType == '신용'
                                    ? AppColors.primary
                                    : AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
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
