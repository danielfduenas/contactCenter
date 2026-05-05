package com.connectcenter.agent.domain.usecases

import com.connectcenter.agent.domain.entities.Credentials
import com.connectcenter.agent.domain.repositories.AuthRepository

/**
 * Use case for agent login
 */
class LoginUseCase(private val authRepository: AuthRepository) {
    suspend operator fun invoke(username: String, password: String) = 
        authRepository.login(Credentials(username, password))
}

/**
 * Use case for agent logout
 */
class LogoutUseCase(private val authRepository: AuthRepository) {
    suspend operator fun invoke() = authRepository.logout()
}

/**
 * Use case for checking session validity
 */
class CheckSessionUseCase(private val authRepository: AuthRepository) {
    suspend operator fun invoke() = authRepository.isSessionValid()
}
