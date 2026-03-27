package org.card.cardservice.dto.response

import org.card.cardservice.domain.category.Category
import org.card.cardservice.domain.category.CategoryGroup

data class CategoryResponse(
    val groups: List<CategoryGroupDto>,
) {
    data class CategoryGroupDto(
        val code: String,
        val displayName: String,
        val categories: List<CategoryDto>,
    )

    data class CategoryDto(
        val code: String,
        val displayName: String,
    )

    companion object {
        fun from(): CategoryResponse {
            val grouped = Category.groupedMap()
            val groups = CategoryGroup.entries.map { group ->
                CategoryGroupDto(
                    code = group.name,
                    displayName = group.displayName,
                    categories = grouped[group]?.map { category ->
                        CategoryDto(
                            code = category.name,
                            displayName = category.displayName,
                        )
                    } ?: emptyList(),
                )
            }
            return CategoryResponse(groups = groups)
        }
    }
}
