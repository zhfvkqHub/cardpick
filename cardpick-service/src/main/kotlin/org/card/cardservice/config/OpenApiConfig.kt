package org.card.cardservice.config

import io.swagger.v3.oas.models.Components
import io.swagger.v3.oas.models.OpenAPI
import io.swagger.v3.oas.models.info.Info
import io.swagger.v3.oas.models.security.SecurityRequirement
import io.swagger.v3.oas.models.security.SecurityScheme
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class OpenApiConfig {

    @Bean
    fun openAPI(): OpenAPI {
        val securityScheme = SecurityScheme()
            .type(SecurityScheme.Type.HTTP)
            .scheme("bearer")
            .bearerFormat("JWT")

        return OpenAPI()
            .info(
                Info()
                    .title("CardPick API")
                    .version("v1")
                    .description("카드 추천 서비스 API")
            )
            .components(Components().addSecuritySchemes("bearerAuth", securityScheme))
            .addSecurityItem(SecurityRequirement().addList("bearerAuth"))
    }
}
