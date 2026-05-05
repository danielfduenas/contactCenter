package com.connectcenter.agent.domain.entities

/**
 * Represents a session state for authentication
 */
data class SessionState(
    val token: String = "",
    val agentId: String = "",
    val isAuthenticated: Boolean = false,
    val expiresAt: Long = 0L
)

/**
 * Represents authentication credentials
 */
data class Credentials(
    val username: String,
    val password: String
)
