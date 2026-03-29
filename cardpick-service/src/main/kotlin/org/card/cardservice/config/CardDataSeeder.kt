package org.card.cardservice.config

import org.card.cardservice.domain.card.Card
import org.card.cardservice.domain.card.CardBenefit
import org.card.cardservice.repository.CardRepository
import org.slf4j.LoggerFactory
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component
import org.springframework.transaction.annotation.Transactional
import java.math.BigDecimal

@Component
@Order(2)
class CardDataSeeder(
    private val cardRepository: CardRepository,
) : ApplicationRunner {

    private val log = LoggerFactory.getLogger(javaClass)

    @Transactional
    override fun run(args: ApplicationArguments) {
        if (cardRepository.count() > 0) {
            log.info("카드 데이터가 이미 존재합니다. 시드 데이터 삽입을 건너뜁니다.")
            return
        }

        log.info("카드 시드 데이터 삽입을 시작합니다.")
        val cards = createSeedCards()
        cardRepository.saveAll(cards)
        log.info("카드 시드 데이터 삽입 완료: {}종 카드, 총 {}건 혜택", cards.size, cards.sumOf { it.benefits.size })
    }

    private fun createSeedCards(): List<Card> {
        return listOf(
            createTaptapO(),
            createDeepDream(),
            createMPoint(),
            createMyWeSh(),
            createLoca365(),
            createPointCard(),
            create1QPay(),
            createOlbareunFlex(),
            createBaroClear(),
            createIdSimple(),
        )
    }

    // 삼성카드 taptap O
    private fun createTaptapO(): Card {
        val card = Card(
            cardCompany = "삼성카드",
            cardName = "taptap O",
            annualFee = 15000,
            cardType = "신용",
            description = "온라인쇼핑·배달·편의점 특화 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "SHOPPING", "SHOPPING_ONLINE", "DISCOUNT", "2.00", "온라인쇼핑 2% 할인"),
            benefit(card, "FOOD", "FOOD_DELIVERY", "DISCOUNT", "3.00", "배달앱 3% 할인"),
            benefit(card, "CONVENIENCE", "CONVENIENCE", "DISCOUNT", "5.00", "편의점 5% 할인"),
        ))
        return card
    }

    // 신한카드 Deep Dream
    private fun createDeepDream(): Card {
        val card = Card(
            cardCompany = "신한카드",
            cardName = "Deep Dream",
            annualFee = 12000,
            cardType = "신용",
            description = "외식·대중교통·OTT 할인 특화 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "FOOD", "FOOD_DINING", "DISCOUNT", "2.00", "외식 2% 할인"),
            benefit(card, "TRANSPORT", "TRANSPORT_PUBLIC", "DISCOUNT", "10.00", "대중교통 10% 할인"),
            benefit(card, "CULTURE", "CULTURE_OTT", "CASHBACK", "5000", "OTT 구독 월 5,000원 캐시백", 5000),
        ))
        return card
    }

    // 현대카드 M포인트
    private fun createMPoint(): Card {
        val card = Card(
            cardCompany = "현대카드",
            cardName = "M포인트",
            annualFee = 15000,
            cardType = "신용",
            description = "백화점·온라인쇼핑·해외결제 포인트 적립 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "SHOPPING", "SHOPPING_DEPARTMENT", "POINT", "2.00", "백화점 2% 포인트 적립"),
            benefit(card, "SHOPPING", "SHOPPING_ONLINE", "POINT", "1.50", "온라인쇼핑 1.5% 포인트 적립"),
            benefit(card, "TRAVEL", "TRAVEL_OVERSEAS", "POINT", "1.50", "해외결제 1.5% 포인트 적립"),
        ))
        return card
    }

    // KB국민카드 My WE:SH
    private fun createMyWeSh(): Card {
        val card = Card(
            cardCompany = "KB국민카드",
            cardName = "My WE:SH",
            annualFee = 10000,
            cardType = "신용",
            description = "카페·대중교통·통신 할인 특화 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "CAFE", "CAFE_GENERAL", "DISCOUNT", "10.00", "카페 10% 할인"),
            benefit(card, "TRANSPORT", "TRANSPORT_PUBLIC", "DISCOUNT", "10.00", "대중교통 10% 할인"),
            benefit(card, "TELECOM", "TELECOM", "DISCOUNT", "5000", "통신요금 월 5,000원 할인", 5000),
        ))
        return card
    }

    // 롯데카드 LOCA 365
    private fun createLoca365(): Card {
        val card = Card(
            cardCompany = "롯데카드",
            cardName = "LOCA 365",
            annualFee = 0,
            cardType = "신용",
            description = "마트·편의점·주유 생활밀착형 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "FOOD", "FOOD_GROCERY", "DISCOUNT", "2.00", "마트 2% 할인"),
            benefit(card, "CONVENIENCE", "CONVENIENCE", "DISCOUNT", "5.00", "편의점 5% 할인"),
            benefit(card, "GAS", "GAS", "DISCOUNT", "3.00", "주유 리터당 3% 할인"),
        ))
        return card
    }

    // 우리카드 카드의정석 POINT
    private fun createPointCard(): Card {
        val card = Card(
            cardCompany = "우리카드",
            cardName = "카드의정석 POINT",
            annualFee = 0,
            cardType = "신용",
            description = "전 가맹점 포인트 적립 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "SHOPPING", null, "POINT", "1.00", "전 가맹점 1% 포인트 적립"),
            benefit(card, "SHOPPING", "SHOPPING_ONLINE", "POINT", "1.50", "온라인쇼핑 1.5% 포인트 적립"),
        ))
        return card
    }

    // 하나카드 1Q Pay#iv
    private fun create1QPay(): Card {
        val card = Card(
            cardCompany = "하나카드",
            cardName = "1Q Pay#iv",
            annualFee = 10000,
            cardType = "신용",
            description = "간편결제·통신·보험 특화 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "SHOPPING", "SHOPPING_ONLINE", "CASHBACK", "5.00", "간편결제 5% 캐시백"),
            benefit(card, "TELECOM", "TELECOM", "DISCOUNT", "3.00", "통신요금 3% 할인"),
            benefit(card, "INSURANCE", "INSURANCE", "CASHBACK", "5000", "보험료 월 5,000원 캐시백", 5000),
        ))
        return card
    }

    // NH농협카드 올바른 FLEX
    private fun createOlbareunFlex(): Card {
        val card = Card(
            cardCompany = "NH농협카드",
            cardName = "올바른 FLEX",
            annualFee = 12000,
            cardType = "신용",
            description = "마트·주유·교통 실속형 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "FOOD", "FOOD_GROCERY", "DISCOUNT", "3.00", "마트 3% 할인"),
            benefit(card, "GAS", "GAS", "DISCOUNT", "5.00", "주유 리터당 5% 할인"),
            benefit(card, "TRANSPORT", "TRANSPORT_PUBLIC", "CASHBACK", "10.00", "대중교통 10% 캐시백"),
        ))
        return card
    }

    // BC카드 바로 클리어
    private fun createBaroClear(): Card {
        val card = Card(
            cardCompany = "BC카드",
            cardName = "바로 클리어",
            annualFee = 0,
            cardType = "신용",
            description = "대중교통 무료·배달 할인 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "TRANSPORT", "TRANSPORT_PUBLIC", "CASHBACK", "100.00", "대중교통 전액 캐시백 (월 1만원 한도)", 10000),
            benefit(card, "FOOD", "FOOD_DELIVERY", "DISCOUNT", "1.00", "배달앱 1% 할인"),
        ))
        return card
    }

    // 삼성카드 iD SIMPLE
    private fun createIdSimple(): Card {
        val card = Card(
            cardCompany = "삼성카드",
            cardName = "iD SIMPLE",
            annualFee = 0,
            cardType = "신용",
            description = "카페·OTT·영화관 라이프스타일 카드",
        )
        card.benefits.addAll(listOf(
            benefit(card, "CAFE", "CAFE_GENERAL", "DISCOUNT", "2.00", "카페 2% 할인"),
            benefit(card, "CULTURE", "CULTURE_OTT", "DISCOUNT", "2.00", "OTT 구독 2% 할인"),
            benefit(card, "CULTURE", "CULTURE_CINEMA", "DISCOUNT", "2.00", "영화관 2% 할인"),
        ))
        return card
    }

    private fun benefit(
        card: Card,
        categoryGroup: String,
        category: String?,
        benefitType: String,
        benefitRate: String,
        description: String,
        benefitLimit: Int? = null,
    ): CardBenefit {
        return CardBenefit(
            card = card,
            categoryGroup = categoryGroup,
            category = category,
            benefitType = benefitType,
            benefitRate = BigDecimal(benefitRate),
            benefitLimit = benefitLimit,
            description = description,
        )
    }
}
