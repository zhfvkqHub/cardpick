class SpendingItem {
  final int? id;
  final String category;
  final int monthlyAmount;

  SpendingItem({this.id, required this.category, required this.monthlyAmount});

  factory SpendingItem.fromJson(Map<String, dynamic> json) => SpendingItem(
        id: json['id'] as int?,
        category: json['category'] as String,
        monthlyAmount: json['monthlyAmount'] as int,
      );

  Map<String, dynamic> toJson() => {
        'category': category,
        'monthlyAmount': monthlyAmount,
      };
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
