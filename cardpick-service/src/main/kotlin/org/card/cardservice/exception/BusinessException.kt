package org.card.cardservice.exception

class BusinessException(
    val errorCode: ErrorCode,
) : RuntimeException(errorCode.message)
