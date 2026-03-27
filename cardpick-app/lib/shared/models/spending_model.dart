class SpendingItem {
  final int? id;
  final String categoryGroup;
  final String? categoryGroupDisplayName;
  final String? category;
  final String? categoryDisplayName;
  final int monthlyAmount;

  SpendingItem({
    this.id,
    required this.categoryGroup,
    this.categoryGroupDisplayName,
    this.category,
    this.categoryDisplayName,
    required this.monthlyAmount,
  });

  factory SpendingItem.fromJson(Map<String, dynamic> json) => SpendingItem(
        id: json['id'] as int?,
        categoryGroup: json['categoryGroup'] as String,
        categoryGroupDisplayName: json['categoryGroupDisplayName'] as String?,
        category: json['category'] as String?,
        categoryDisplayName: json['categoryDisplayName'] as String?,
        monthlyAmount: json['monthlyAmount'] as int,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'categoryGroup': categoryGroup,
      'monthlyAmount': monthlyAmount,
    };
    if (category != null) map['category'] = category;
    return map;
  }
}

class SpendingProfileResponse {
  final List<SpendingItem> items;

  const SpendingProfileResponse({required this.items});

  factory SpendingProfileResponse.fromJson(Map<String, dynamic> json) =>
      SpendingProfileResponse(
        items: (json['items'] as List)
            .map((i) => SpendingItem.fromJson(i as Map<String, dynamic>))
            .toList(),
      );
}
