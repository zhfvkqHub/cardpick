import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../shared/models/recommendation_model.dart';
import '../../shared/providers/recommendation_provider.dart';
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
      // 추천 결과가 없으면 자동으로 추천 실행
      try {
        await ref.read(recommendationProvider.notifier).recommend();
      } catch (_) {
        // 소비 프로필 미등록 등 실패 시 무시 (빈 화면 표시)
      }
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.stars_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              '소비 패턴을 분석하여\n최적의 카드를 추천해 드립니다',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRecommend,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('카드 추천 받기'),
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

  const _RecommendationResult(
      {required this.recommendation, required this.onReRequest});

  @override
  Widget build(BuildContext context) {
    final dt = recommendation.createdAt;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (dt != null)
                Text(
                  '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')} 기준',
                  style:
                      const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              TextButton.icon(
                onPressed: onReRequest,
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('재추천'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recommendation.cards.length,
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

  const _RecommendedCardItem(
      {required this.card, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isTop = card.rank == 1;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isTop ? 4 : 1,
      shape: isTop
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2),
            )
          : RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _RankBadge(rank: card.rank),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.cardName,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        Text(
                          card.cardCompany,
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _SavingInfo(
                      label: '총 절감액',
                      amount: card.totalSaving,
                      color: Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _SavingInfo(
                      label: '순 절감액',
                      amount: card.netSaving,
                      color: card.netSaving >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                  Expanded(
                    child: _SavingInfo(
                      label: '연회비',
                      amount: card.annualFee.toDouble(),
                      color: Colors.orange,
                      isAnnualFee: true,
                    ),
                  ),
                ],
              ),
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
    final colors = [Colors.amber, Colors.grey.shade400, Colors.brown.shade300];
    final color = rank <= 3
        ? colors[rank - 1]
        : Theme.of(context).colorScheme.surfaceContainerHighest;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: Text(
          '$rank',
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}

class _SavingInfo extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isAnnualFee;

  const _SavingInfo({
    required this.label,
    required this.amount,
    required this.color,
    this.isAnnualFee = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = isAnnualFee
        ? (amount == 0 ? '무료' : '${_fmt(amount.toInt())}원')
        : '${amount >= 0 ? '+' : '-'}${_fmt(amount.abs().toInt())}원';

    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
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
