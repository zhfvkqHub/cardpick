class CategoryDto {
  final String code;
  final String displayName;

  CategoryDto({required this.code, required this.displayName});

  factory CategoryDto.fromJson(Map<String, dynamic> json) => CategoryDto(
        code: json['code'] as String,
        displayName: json['displayName'] as String,
      );
}

class CategoryGroupDto {
  final String code;
  final String displayName;
  final List<CategoryDto> categories;

  CategoryGroupDto({
    required this.code,
    required this.displayName,
    required this.categories,
  });

  factory CategoryGroupDto.fromJson(Map<String, dynamic> json) =>
      CategoryGroupDto(
        code: json['code'] as String,
        displayName: json['displayName'] as String,
        categories: (json['categories'] as List)
            .map((c) => CategoryDto.fromJson(c as Map<String, dynamic>))
            .toList(),
      );
}

class CategoryResponse {
  final List<CategoryGroupDto> groups;

  CategoryResponse({required this.groups});

  factory CategoryResponse.fromJson(Map<String, dynamic> json) =>
      CategoryResponse(
        groups: (json['groups'] as List)
            .map((g) => CategoryGroupDto.fromJson(g as Map<String, dynamic>))
            .toList(),
      );
}
