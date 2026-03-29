package org.card.cardservice.service

import org.slf4j.LoggerFactory
import org.springframework.stereotype.Service

@Service
class CardCollectorService {
    private val log = LoggerFactory.getLogger(javaClass)

    /**
     * 외부 API를 통한 카드 수집.
     * 현재 한국에 신용카드 상품 정보를 제공하는 공공 API가 없어 비활성화 상태.
     * 향후 실제 API 연동 시 재구현 예정.
     */
    fun collectCards(): Int {
        log.info("외부 카드 수집 API가 현재 비활성화되어 있습니다.")
        return 0
    }
}
