package org.card.cardservice.service

import org.card.cardservice.domain.card.PendingCard
import org.card.cardservice.domain.card.PendingStatus
import org.card.cardservice.repository.CardRepository
import org.card.cardservice.repository.PendingCardRepository
import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import org.springframework.web.reactive.function.client.WebClient

@Service
class CardCollectorService(
    private val cardRepository: CardRepository,
    private val pendingCardRepository: PendingCardRepository,
    @Value("\${app.fss.api-key:}") private val fssApiKey: String,
) {
    private val log = LoggerFactory.getLogger(javaClass)
    private val webClient = WebClient.builder()
        .baseUrl("http://finlife.fss.or.kr/finlifeapi")
        .build()

    @Transactional
    fun collectCards(): Int {
        if (fssApiKey.isBlank()) {
            log.warn("FSS API 키가 설정되지 않았습니다. 카드 수집을 건너뜁니다.")
            return 0
        }

        log.info("금융감독원 카드 상품 수집을 시작합니다.")

        val response = try {
            webClient.get()
                .uri("/creditCardTop10.json?auth={key}&topFinGrpNo=060300&pageNo=1", fssApiKey)
                .retrieve()
                .bodyToMono(FssApiResponse::class.java)
                .block()
        } catch (e: Exception) {
            log.error("금융감독원 API 호출 실패: {}", e.message)
            return 0
        }

        if (response?.result?.baseList == null) {
            log.warn("금융감독원 API 응답에 데이터가 없습니다.")
            return 0
        }

        var savedCount = 0
        for (item in response.result.baseList) {
            val cardCompany = item.korCoNm ?: continue
            val cardName = item.crdPrdtNm ?: continue

            // 기존 Card 테이블 중복 체크
            if (cardRepository.findByCardNameAndCardCompany(cardName, cardCompany) != null) {
                continue
            }

            // PendingCard 테이블 중복 체크
            if (pendingCardRepository.findByCardNameAndCardCompany(cardName, cardCompany) != null) {
                continue
            }

            val pendingCard = PendingCard(
                cardCompany = cardCompany,
                cardName = cardName,
                annualFee = item.annualFee1 ?: 0,
                cardType = "신용",
                imageUrl = null,
                description = item.crdPrdtNm,
                source = "FSS_API",
                status = PendingStatus.PENDING,
            )
            pendingCardRepository.save(pendingCard)
            savedCount++
        }

        log.info("카드 수집 완료: {}건 신규 등록", savedCount)
        return savedCount
    }

    fun isApiKeyConfigured(): Boolean = fssApiKey.isNotBlank()
}

data class FssApiResponse(
    val result: FssResult = FssResult(),
)

data class FssResult(
    val baseList: List<FssCardItem> = emptyList(),
)

data class FssCardItem(
    val korCoNm: String? = null,
    val crdPrdtNm: String? = null,
    val annualFee1: Int? = null,
)
