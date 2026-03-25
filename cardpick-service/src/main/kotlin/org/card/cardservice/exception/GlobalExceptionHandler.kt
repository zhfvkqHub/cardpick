package org.card.cardservice.exception

import jakarta.validation.ConstraintViolationException
import org.card.cardservice.dto.response.ApiResponse
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {

    @ExceptionHandler(BusinessException::class)
    fun handleBusinessException(e: BusinessException): ResponseEntity<ApiResponse<Nothing>> {
        val errorCode = e.errorCode
        return ResponseEntity
            .status(errorCode.status)
            .body(ApiResponse.error(errorCode.code, errorCode.message))
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidationException(e: MethodArgumentNotValidException): ResponseEntity<ApiResponse<Nothing>> {
        val message = e.bindingResult.fieldErrors
            .joinToString(", ") { "${it.field}: ${it.defaultMessage}" }
        return ResponseEntity
            .badRequest()
            .body(ApiResponse.error(ErrorCode.INVALID_INPUT.code, message))
    }

    @ExceptionHandler(ConstraintViolationException::class)
    fun handleConstraintViolationException(e: ConstraintViolationException): ResponseEntity<ApiResponse<Nothing>> {
        val message = e.constraintViolations
            .joinToString(", ") { it.message }
        return ResponseEntity
            .badRequest()
            .body(ApiResponse.error(ErrorCode.INVALID_INPUT.code, message))
    }

    @ExceptionHandler(Exception::class)
    fun handleException(e: Exception): ResponseEntity<ApiResponse<Nothing>> {
        return ResponseEntity
            .internalServerError()
            .body(ApiResponse.error(ErrorCode.INTERNAL_ERROR.code, ErrorCode.INTERNAL_ERROR.message))
    }
}
