package org.card.cardservice.config

import org.card.cardservice.service.CardCollectorService
import org.slf4j.LoggerFactory
import org.springframework.context.annotation.Configuration
import org.springframework.scheduling.annotation.EnableScheduling
import org.springframework.scheduling.annotation.Scheduled

@Configuration
@EnableScheduling
class SchedulerConfig(
    private val cardCollectorService: CardCollectorService,
) {
    private val log = LoggerFactory.getLogger(javaClass)

    @Scheduled(cron = "0 0 6 * * *")
    fun scheduledCardCollection() {
        if (!cardCollectorService.isApiKeyConfigured()) {
            log.debug("FSS API 키 미설정 - 스케줄 수집 skip")
            return
        }
        log.info("스케줄 카드 수집 시작")
        val count = cardCollectorService.collectCards()
        log.info("스케줄 카드 수집 완료: {}건", count)
    }
}
