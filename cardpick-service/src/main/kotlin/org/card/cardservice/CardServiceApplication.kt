package org.card.cardservice

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.context.properties.ConfigurationPropertiesScan
import org.springframework.boot.runApplication

@SpringBootApplication
@ConfigurationPropertiesScan
class CardServiceApplication

fun main(args: Array<String>) {
    runApplication<CardServiceApplication>(*args)
}
