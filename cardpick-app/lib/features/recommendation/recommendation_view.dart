import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme.dart';
import '../../shared/models/recommendation_model.dart';
import '../../shared/providers/recommendation_provider.dart';
import '../../shared/utils/format_utils.dart';
import '../../shared/widgets/common_widgets.dart';

class RecommendationView extends ConsumerStatefulWidget {
  const RecommendationView({super.key});

  @override
  ConsumerState<RecommendationView> createState() =>
      _RecommendationViewState();
}

class _RecommendationViewState extends ConsumerState<RecommendationView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadOrRecommend());
  }

  Future<void> _loadOrRecommend() async {
    await ref.read(recommendationProvider.notifier).loadLatest();
    final result = ref.read(recommendationProvider).valueOrNull;
    if (result == null && mounted) {
      try {
        await ref.read(recommendationProvider.notifier).recommend();
      } catch (_) {}
    }
  }

  Future<void> _recommend() async {
    try {
      await ref.read(recommendationProvider.notifier).recommend();
    } catch (e) {
      if (mounted) {
        showErrorSnackBar(
            context, e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recAsync = ref.watch(recommendationProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('카드 추천')),
      body: recAsync.when(
        loading: () => const LoadingOverlay(),
        error: (_, __) => ErrorView(
          message: '추천 결과를 불러오지 못했습니다',
          onRetry: _recommend,
        ),
        data: (rec) => (rec == null || rec.cards.isEmpty)
            ? _EmptyRecommendation(onRecommend: _recommend)
            : _RecommendationResult(
                recommendation: rec, onReRequest: _recommend),
      ),
    );
  }
}

class _EmptyRecommendation extends StatelessWidget {
  final VoidCallback onRecommend;

  const _EmptyRecommendation({required this.onRecommend});

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
                Icons.auto_awesome_rounded,
                size: 44,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '나에게 맞는 카드 찾기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '소비 패턴을 분석하여\n최적의 카드를 추천해 드립니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onRecommend,
              icon: const Icon(Icons.auto_awesome_rounded, size: 20),
              label: const Text('카드 추천 받기'),
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

class _RecommendationResult extends StatelessWidget {
  final RecommendationResponse recommendation;
  final VoidCallback onReRequest;

  const _RecommendationResult({
    required this.recommendation,
    required this.onReRequest,
  });

  @override
  Widget build(BuildContext context) {
    final dt = recommendation.createdAt;
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 0),
          child: Row(
            children: [
              if (dt != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} 기준',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              TextButton.icon(
                onPressed: onReRequest,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('재추천'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),

        // Card list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: recommendation.cards.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) => _RecommendedCardItem(
              card: recommendation.cards[i],
              onTap: () => context
                  .push('/cards/${recommendation.cards[i].cardId}'),
            ),
          ),
        ),
      ],
    );
  }
}

class _RecommendedCardItem extends StatelessWidget {
  final RecommendedCard card;
  final VoidCallback onTap;

  const _RecommendedCardItem({required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTop = card.rank == 1;

    return Card(
      elevation: isTop ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isTop
            ? const BorderSide(color: AppColors.primary, width: 1.5)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RankBadge(rank: card.rank),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.cardName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          card.cardCompany,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textHint, size: 20),
                ],
              ),
              const SizedBox(height: 16),

              // Savings info
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _SavingColumn(
                        label: '총 절감',
                        amount: card.totalSaving,
                        color: AppColors.primary,
                        prefix: '+',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _SavingColumn(
                        label: '순 절감',
                        amount: card.netSaving,
                        color: card.netSaving >= 0
                            ? AppColors.success
                            : AppColors.accent,
                        prefix: card.netSaving >= 0 ? '+' : '',
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: _SavingColumn(
                        label: '연회비',
                        amount: card.annualFee.toDouble(),
                        color: AppColors.warning,
                        isAnnualFee: true,
                      ),
                    ),
                  ],
                ),
              ),

              // Best pick badge for rank 1
              if (isTop) ...[
                const SizedBox(height: 12),
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium_rounded,
                            size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          '나에게 가장 유리한 카드',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _RankBadge extends StatelessWidget {
  final int rank;

  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final isTopThree = rank <= 3;
    final colors = [
      const Color(0xFFFFB020), // Gold
      const Color(0xFF94A3B8), // Silver
      const Color(0xFFCD7F32), // Bronze
    ];
    final bgColor = isTopThree ? colors[rank - 1] : AppColors.textHint;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: isTopThree ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          '$rank',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: isTopThree ? bgColor : AppColors.textHint,
          ),
        ),
      ),
    );
  }
}

class _SavingColumn extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final String? prefix;
  final bool isAnnualFee;

  const _SavingColumn({
    required this.label,
    required this.amount,
    required this.color,
    this.prefix,
    this.isAnnualFee = false,
  });

  @override
  Widget build(BuildContext context) {
    String text;
    if (isAnnualFee) {
      text = amount == 0 ? '무료' : '${formatCurrency(amount.toInt())}원';
    } else {
      text =
          '${prefix ?? ''}${formatCurrency(amount.abs().toInt())}원';
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textHint,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}
