package org.card.cardservice.controller

import io.swagger.v3.oas.annotations.Operation
import io.swagger.v3.oas.annotations.tags.Tag
import org.card.cardservice.dto.response.ApiResponse
import org.card.cardservice.dto.response.CategoryResponse
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@Tag(name = "카테고리", description = "카테고리 목록 조회 API (공개)")
@RestController
@RequestMapping("/api/v1/categories")
class CategoryController {

    @Operation(summary = "카테고리 목록 조회 (대분류/소분류)")
    @GetMapping
    fun getCategories(): ApiResponse<CategoryResponse> {
        return ApiResponse.ok(CategoryResponse.from())
    }
}
