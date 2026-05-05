package com.connectcenter.agent.data.repositories

import com.connectcenter.agent.domain.entities.Credentials
import com.connectcenter.agent.domain.entities.SessionState
import com.connectcenter.agent.domain.repositories.AuthRepository
import android.content.SharedPreferences

/**
 * Implementation of AuthRepository
 */
class AuthRepositoryImpl(
    private val sharedPreferences: SharedPreferences
) : AuthRepository {
    
    override suspend fun login(credentials: Credentials): Result<SessionState> {
        return try {
            // TODO: Call AWS Connect or authentication service
            // For demo, create a fake session
            val sessionState = SessionState(
                token = "fake-token-${System.currentTimeMillis()}",
                agentId = "agent-123",
                isAuthenticated = true,
                expiresAt = System.currentTimeMillis() + 3600000 // 1 hour
            )
            
            // Save to SharedPreferences
            saveSession(sessionState)
            
            Result.success(sessionState)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun logout(): Result<Boolean> {
        return try {
            // Clear session from SharedPreferences
            sharedPreferences.edit().clear().apply()
            Result.success(true)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun getSessionState(): Result<SessionState> {
        return try {
            val token = sharedPreferences.getString("session_token", "") ?: ""
            val agentId = sharedPreferences.getString("agent_id", "") ?: ""
            val expiresAt = sharedPreferences.getLong("expires_at", 0L)
            
            val isAuthenticated = token.isNotEmpty() && expiresAt > System.currentTimeMillis()
            
            val sessionState = SessionState(
                token = token,
                agentId = agentId,
                isAuthenticated = isAuthenticated,
                expiresAt = expiresAt
            )
            
            Result.success(sessionState)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    override suspend fun isSessionValid(): Boolean {
        return try {
            val sessionResult = getSessionState()
            sessionResult.getOrNull()?.isAuthenticated ?: false
        } catch (e: Exception) {
            false
        }
    }
    
    override suspend fun refreshToken(): Result<String> {
        return try {
            // TODO: Call refresh token endpoint
            val newToken = "refreshed-token-${System.currentTimeMillis()}"
            sharedPreferences.edit().putString("session_token", newToken).apply()
            Result.success(newToken)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    private fun saveSession(sessionState: SessionState) {
        sharedPreferences.edit().apply {
            putString("session_token", sessionState.token)
            putString("agent_id", sessionState.agentId)
            putLong("expires_at", sessionState.expiresAt)
            apply()
        }
    }
}
