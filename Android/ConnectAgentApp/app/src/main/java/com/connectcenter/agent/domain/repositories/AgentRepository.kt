package com.connectcenter.agent.domain.repositories

import com.connectcenter.agent.domain.entities.Agent
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for agent operations
 */
interface AgentRepository {
    /**
     * Gets current agent status
     */
    suspend fun getAgentStatus(): Result<Agent>
    
    /**
     * Sets agent status
     */
    suspend fun setAgentStatus(state: String): Result<Boolean>
    
    /**
     * Monitors agent state changes
     */
    fun monitorAgentStatus(): Flow<Agent>
}
