package org.card.cardservice.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "app.init.admin")
data class InitAdminProperties(
    val loginId: String = "",
    val password: String = "",
    val name: String = "",
)
