package com.connectcenter.agent.domain.usecases

import com.connectcenter.agent.domain.repositories.CallRepository

/**
 * Use case for accepting an incoming call
 */
class AcceptCallUseCase(private val callRepository: CallRepository) {
    suspend operator fun invoke(contactId: String): Result<Boolean> {
        return try {
            callRepository.acceptCall(contactId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

/**
 * Use case for rejecting an incoming call
 */
class RejectCallUseCase(private val callRepository: CallRepository) {
    suspend operator fun invoke(contactId: String): Result<Boolean> {
        return try {
            callRepository.rejectCall(contactId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

/**
 * Use case for ending an active call
 */
class EndCallUseCase(private val callRepository: CallRepository) {
    suspend operator fun invoke(contactId: String): Result<Boolean> {
        return try {
            callRepository.endCall(contactId)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

/**
 * Use case for toggling mute
 */
class ToggleMuteUseCase(private val callRepository: CallRepository) {
    suspend operator fun invoke(contactId: String, isMuted: Boolean): Result<Boolean> {
        return try {
            callRepository.toggleMute(contactId, isMuted)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}

/**
 * Use case for toggling hold
 */
class ToggleHoldUseCase(private val callRepository: CallRepository) {
    suspend operator fun invoke(contactId: String, onHold: Boolean): Result<Boolean> {
        return try {
            callRepository.toggleHold(contactId, onHold)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
