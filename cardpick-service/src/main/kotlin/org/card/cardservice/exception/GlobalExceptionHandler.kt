package org.card.cardservice.exception

import jakarta.validation.ConstraintViolationException
import org.card.cardservice.dto.response.ApiResponse
import org.slf4j.LoggerFactory
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.MethodArgumentNotValidException
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.bind.annotation.RestControllerAdvice

@RestControllerAdvice
class GlobalExceptionHandler {

    private val log = LoggerFactory.getLogger(GlobalExceptionHandler::class.java)

    @ExceptionHandler(BusinessException::class)
    fun handleBusinessException(e: BusinessException): ResponseEntity<ApiResponse<Nothing>> {
        val errorCode = e.errorCode
        log.warn("Business exception: code={}, message={}", errorCode.code, errorCode.message)
        return ResponseEntity
            .status(errorCode.status)
            .body(ApiResponse.error(errorCode.code, errorCode.message))
    }

    @ExceptionHandler(MethodArgumentNotValidException::class)
    fun handleValidationException(e: MethodArgumentNotValidException): ResponseEntity<ApiResponse<Nothing>> {
        val message = e.bindingResult.fieldErrors
            .joinToString(", ") { "${it.field}: ${it.defaultMessage}" }
        log.warn("Validation exception: {}", message)
        return ResponseEntity
            .badRequest()
            .body(ApiResponse.error(ErrorCode.INVALID_INPUT.code, message))
    }

    @ExceptionHandler(ConstraintViolationException::class)
    fun handleConstraintViolationException(e: ConstraintViolationException): ResponseEntity<ApiResponse<Nothing>> {
        val message = e.constraintViolations
            .joinToString(", ") { it.message }
        log.warn("Constraint violation: {}", message)
        return ResponseEntity
            .badRequest()
            .body(ApiResponse.error(ErrorCode.INVALID_INPUT.code, message))
    }

    @ExceptionHandler(Exception::class)
    fun handleException(e: Exception): ResponseEntity<ApiResponse<Nothing>> {
        log.error("Unhandled exception", e)
        return ResponseEntity
            .internalServerError()
            .body(ApiResponse.error(ErrorCode.INTERNAL_ERROR.code, ErrorCode.INTERNAL_ERROR.message))
    }
}
