class CardResponse {
  final int id;
  final String cardCompany;
  final String cardName;
  final int annualFee;
  final String cardType;
  final String? imageUrl;
  final bool isActive;

  CardResponse({
    required this.id,
    required this.cardCompany,
    required this.cardName,
    required this.annualFee,
    required this.cardType,
    this.imageUrl,
    required this.isActive,
  });

  factory CardResponse.fromJson(Map<String, dynamic> json) => CardResponse(
        id: json['id'] as int,
        cardCompany: json['cardCompany'] as String,
        cardName: json['cardName'] as String,
        annualFee: json['annualFee'] as int,
        cardType: json['cardType'] as String? ?? '',
        imageUrl: json['imageUrl'] as String?,
        isActive: json['isActive'] as bool,
      );
}

class BenefitResponse {
  final int id;
  final String categoryGroup;
  final String categoryGroupDisplayName;
  final String? category;
  final String? categoryDisplayName;
  final String benefitType;
  final double benefitRate;
  final int? benefitLimit;
  final int? minimumAmount;
  final String? description;

  BenefitResponse({
    required this.id,
    required this.categoryGroup,
    required this.categoryGroupDisplayName,
    this.category,
    this.categoryDisplayName,
    required this.benefitType,
    required this.benefitRate,
    this.benefitLimit,
    this.minimumAmount,
    this.description,
  });

  factory BenefitResponse.fromJson(Map<String, dynamic> json) => BenefitResponse(
        id: json['id'] as int,
        categoryGroup: json['categoryGroup'] as String,
        categoryGroupDisplayName: json['categoryGroupDisplayName'] as String,
        category: json['category'] as String?,
        categoryDisplayName: json['categoryDisplayName'] as String?,
        benefitType: json['benefitType'] as String,
        benefitRate: (json['benefitRate'] as num).toDouble(),
        benefitLimit: json['benefitLimit'] as int?,
        minimumAmount: json['minimumAmount'] as int?,
        description: json['description'] as String?,
      );
}

class CardDetailResponse {
  final int id;
  final String cardCompany;
  final String cardName;
  final int annualFee;
  final int? minimumSpending;
  final String cardType;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final List<BenefitResponse> benefits;

  CardDetailResponse({
    required this.id,
    required this.cardCompany,
    required this.cardName,
    required this.annualFee,
    this.minimumSpending,
    required this.cardType,
    this.imageUrl,
    this.description,
    required this.isActive,
    required this.benefits,
  });

  factory CardDetailResponse.fromJson(Map<String, dynamic> json) => CardDetailResponse(
        id: json['id'] as int,
        cardCompany: json['cardCompany'] as String,
        cardName: json['cardName'] as String,
        annualFee: json['annualFee'] as int,
        minimumSpending: json['minimumSpending'] as int?,
        cardType: json['cardType'] as String,
        imageUrl: json['imageUrl'] as String?,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool,
        benefits: (json['benefits'] as List)
            .map((b) => BenefitResponse.fromJson(b as Map<String, dynamic>))
            .toList(),
      );
}
