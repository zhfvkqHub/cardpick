package org.card.cardservice.domain.category

enum class CategoryGroup(
    val displayName: String,
) {
    FOOD("식비"),
    CAFE("카페"),
    TRANSPORT("교통"),
    SHOPPING("쇼핑"),
    CONVENIENCE("편의점"),
    TELECOM("통신"),
    GAS("주유"),
    CULTURE("여가/문화"),
    TRAVEL("여행"),
    MEDICAL("의료"),
    INSURANCE("보험"),
    EDUCATION("교육"),
    ;

    companion object {
        fun fromCode(code: String): CategoryGroup? = entries.find { it.name == code }
    }
}

enum class Category(
    val group: CategoryGroup,
    val displayName: String,
) {
    // 식비
    FOOD_DELIVERY(CategoryGroup.FOOD, "배달"),
    FOOD_DINING(CategoryGroup.FOOD, "외식"),
    FOOD_GROCERY(CategoryGroup.FOOD, "마트/장보기"),

    // 카페
    CAFE_STARBUCKS(CategoryGroup.CAFE, "스타벅스"),
    CAFE_GENERAL(CategoryGroup.CAFE, "일반카페"),

    // 교통
    TRANSPORT_PUBLIC(CategoryGroup.TRANSPORT, "대중교통"),
    TRANSPORT_TAXI(CategoryGroup.TRANSPORT, "택시"),
    TRANSPORT_EXPRESS(CategoryGroup.TRANSPORT, "고속/KTX"),

    // 쇼핑
    SHOPPING_ONLINE(CategoryGroup.SHOPPING, "온라인쇼핑"),
    SHOPPING_DEPARTMENT(CategoryGroup.SHOPPING, "백화점"),
    SHOPPING_OFFLINE(CategoryGroup.SHOPPING, "오프라인매장"),

    // 편의점
    CONVENIENCE(CategoryGroup.CONVENIENCE, "편의점"),

    // 통신
    TELECOM(CategoryGroup.TELECOM, "통신"),

    // 주유
    GAS(CategoryGroup.GAS, "주유"),

    // 여가/문화
    CULTURE_OTT(CategoryGroup.CULTURE, "OTT"),
    CULTURE_CINEMA(CategoryGroup.CULTURE, "영화관"),
    CULTURE_PERFORMANCE(CategoryGroup.CULTURE, "공연/전시"),

    // 여행
    TRAVEL_FLIGHT(CategoryGroup.TRAVEL, "항공"),
    TRAVEL_ACCOMMODATION(CategoryGroup.TRAVEL, "숙박"),
    TRAVEL_OVERSEAS(CategoryGroup.TRAVEL, "해외결제"),

    // 의료
    MEDICAL(CategoryGroup.MEDICAL, "의료"),

    // 보험
    INSURANCE(CategoryGroup.INSURANCE, "보험"),

    // 교육
    EDUCATION(CategoryGroup.EDUCATION, "교육"),
    ;

    companion object {
        fun fromCode(code: String): Category? = entries.find { it.name == code }

        fun groupedMap(): Map<CategoryGroup, List<Category>> =
            entries.groupBy { it.group }
    }
}
