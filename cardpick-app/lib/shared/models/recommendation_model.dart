class RecommendedCard {
  final int rank;
  final int cardId;
  final String cardName;
  final String cardCompany;
  final String cardType;
  final int annualFee;
  final double totalSaving;
  final double netSaving;

  RecommendedCard({
    required this.rank,
    required this.cardId,
    required this.cardName,
    required this.cardCompany,
    required this.cardType,
    required this.annualFee,
    required this.totalSaving,
    required this.netSaving,
  });

  factory RecommendedCard.fromJson(Map<String, dynamic> json) => RecommendedCard(
        rank: json['rank'] as int,
        cardId: json['cardId'] as int,
        cardName: json['cardName'] as String,
        cardCompany: json['cardCompany'] as String,
        cardType: json['cardType'] as String? ?? '',
        annualFee: json['annualFee'] as int,
        totalSaving: (json['totalSaving'] as num).toDouble(),
        netSaving: (json['netSaving'] as num).toDouble(),
      );
}

class RecommendationResponse {
  final String requestId;
  final DateTime? createdAt;
  final List<RecommendedCard> cards;

  RecommendationResponse({
    required this.requestId,
    this.createdAt,
    required this.cards,
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) =>
      RecommendationResponse(
        requestId: json['requestId'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        cards: (json['cards'] as List)
            .map((c) => RecommendedCard.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}
