package org.card.cardservice.config

import org.card.cardservice.domain.admin.Admin
import org.card.cardservice.repository.AdminRepository
import org.slf4j.LoggerFactory
import org.springframework.boot.ApplicationArguments
import org.springframework.boot.ApplicationRunner
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Component

@Component
@ConditionalOnProperty(prefix = "app.init.admin", name = ["login-id"])
class DataInitializer(
    private val adminRepository: AdminRepository,
    private val passwordEncoder: PasswordEncoder,
    private val properties: InitAdminProperties,
) : ApplicationRunner {

    private val log = LoggerFactory.getLogger(javaClass)

    override fun run(args: ApplicationArguments) {
        if (adminRepository.findByLoginId(properties.loginId) != null) {
            log.info("초기 관리자 계정이 이미 존재합니다: {}", properties.loginId)
            return
        }

        val admin = Admin(
            loginId = properties.loginId,
            passwordHash = passwordEncoder.encode(properties.password),
            name = properties.name,
        )
        adminRepository.save(admin)
        log.info("초기 관리자 계정 생성 완료: {}", properties.loginId)
    }
}
