package com.connectcenter.agent.domain.repositories

import com.connectcenter.agent.domain.entities.Credentials
import com.connectcenter.agent.domain.entities.SessionState

/**
 * Repository interface for authentication
 */
interface AuthRepository {
    /**
     * Performs login with credentials
     */
    suspend fun login(credentials: Credentials): Result<SessionState>
    
    /**
     * Performs logout
     */
    suspend fun logout(): Result<Boolean>
    
    /**
     * Gets current session state
     */
    suspend fun getSessionState(): Result<SessionState>
    
    /**
     * Checks if session is valid
     */
    suspend fun isSessionValid(): Boolean
    
    /**
     * Refreshes authentication token
     */
    suspend fun refreshToken(): Result<String>
}
