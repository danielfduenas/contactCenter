package com.connectcenter.agent.domain.entities

/**
 * Represents the different states a call can be in
 */
enum class CallState {
    IDLE,
    INCOMING,
    RINGING,
    CONNECTED,
    MUTED,
    ON_HOLD,
    DISCONNECTING,
    DISCONNECTED
}

/**
 * Represents a call
 */
data class Call(
    val id: String,
    val contactId: String,
    val callerId: String,
    val callerName: String,
    val state: CallState = CallState.IDLE,
    val duration: Long = 0L,
    val timestamp: Long = System.currentTimeMillis(),
    val attributes: Map<String, String> = emptyMap()
) {
    val isActive: Boolean
        get() = state in listOf(CallState.CONNECTED, CallState.MUTED, CallState.ON_HOLD)
}
