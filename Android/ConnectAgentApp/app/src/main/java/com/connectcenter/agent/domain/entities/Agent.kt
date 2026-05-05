package com.connectcenter.agent.domain.entities

/**
 * Represents the different states an agent can be in
 */
enum class AgentState {
    OFFLINE,
    AVAILABLE,
    ON_CONTACT,
    AFTER_CONTACT_WORK,
    ERROR
}

/**
 * Represents an agent user
 */
data class Agent(
    val id: String,
    val username: String,
    val name: String,
    val state: AgentState = AgentState.OFFLINE,
    val routingProfile: String = "",
    val queue: String = "",
    val extension: String? = null
)
