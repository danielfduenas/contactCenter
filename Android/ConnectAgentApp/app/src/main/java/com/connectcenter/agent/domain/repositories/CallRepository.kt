package com.connectcenter.agent.domain.repositories

import com.connectcenter.agent.domain.entities.Call
import kotlinx.coroutines.flow.Flow

/**
 * Repository interface for call operations
 */
interface CallRepository {
    /**
     * Accepts an incoming call
     */
    suspend fun acceptCall(contactId: String): Result<Boolean>
    
    /**
     * Rejects an incoming call
     */
    suspend fun rejectCall(contactId: String): Result<Boolean>
    
    /**
     * Ends an active call
     */
    suspend fun endCall(contactId: String): Result<Boolean>
    
    /**
     * Toggles mute on active call
     */
    suspend fun toggleMute(contactId: String, isMuted: Boolean): Result<Boolean>
    
    /**
     * Puts call on hold or resumes
     */
    suspend fun toggleHold(contactId: String, onHold: Boolean): Result<Boolean>
    
    /**
     * Gets call attributes
     */
    suspend fun getCallAttributes(contactId: String): Result<Map<String, String>>
    
    /**
     * Updates call attributes
     */
    suspend fun updateCallAttributes(
        contactId: String,
        attributes: Map<String, String>
    ): Result<Boolean>
    
    /**
     * Monitors call status changes
     */
    fun monitorCallStatus(contactId: String): Flow<Call>
}
