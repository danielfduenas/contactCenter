package com.connectcenter.agent.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.connectcenter.agent.domain.entities.Call
import com.connectcenter.agent.domain.entities.CallState
import com.connectcenter.agent.domain.entities.Agent
import com.connectcenter.agent.domain.usecases.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for managing call state
 */
class CallViewModel(
    private val acceptCallUseCase: AcceptCallUseCase,
    private val rejectCallUseCase: RejectCallUseCase,
    private val endCallUseCase: EndCallUseCase,
    private val toggleMuteUseCase: ToggleMuteUseCase,
    private val toggleHoldUseCase: ToggleHoldUseCase
) : ViewModel() {
    
    private val _incomingCall = MutableStateFlow<Call?>(null)
    val incomingCall: StateFlow<Call?> = _incomingCall.asStateFlow()
    
    private val _callState = MutableStateFlow<CallState>(CallState.IDLE)
    val callState: StateFlow<CallState> = _callState.asStateFlow()
    
    private val _callDuration = MutableStateFlow(0L)
    val callDuration: StateFlow<Long> = _callDuration.asStateFlow()
    
    private val _isMuted = MutableStateFlow(false)
    val isMuted: StateFlow<Boolean> = _isMuted.asStateFlow()
    
    private val _isOnHold = MutableStateFlow(false)
    val isOnHold: StateFlow<Boolean> = _isOnHold.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    fun acceptCall(call: Call) {
        viewModelScope.launch {
            val result = acceptCallUseCase(call.contactId)
            
            result.onSuccess {
                _incomingCall.value = call.copy(state = CallState.CONNECTED)
                _callState.value = CallState.CONNECTED
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Failed to accept call"
            }
        }
    }
    
    fun rejectCall(contactId: String) {
        viewModelScope.launch {
            val result = rejectCallUseCase(contactId)
            
            result.onSuccess {
                _incomingCall.value = null
                _callState.value = CallState.IDLE
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Failed to reject call"
            }
        }
    }
    
    fun endCall() {
        viewModelScope.launch {
            val contactId = _incomingCall.value?.contactId ?: return@launch
            
            val result = endCallUseCase(contactId)
            
            result.onSuccess {
                _incomingCall.value = null
                _callState.value = CallState.DISCONNECTED
                _callDuration.value = 0L
                _isMuted.value = false
                _isOnHold.value = false
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Failed to end call"
            }
        }
    }
    
    fun toggleMute() {
        viewModelScope.launch {
            val contactId = _incomingCall.value?.contactId ?: return@launch
            val newMuteState = !_isMuted.value
            
            val result = toggleMuteUseCase(contactId, newMuteState)
            
            result.onSuccess {
                _isMuted.value = newMuteState
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Failed to toggle mute"
            }
        }
    }
    
    fun toggleHold() {
        viewModelScope.launch {
            val contactId = _incomingCall.value?.contactId ?: return@launch
            val newHoldState = !_isOnHold.value
            
            val result = toggleHoldUseCase(contactId, newHoldState)
            
            result.onSuccess {
                _isOnHold.value = newHoldState
                _callState.value = if (newHoldState) CallState.ON_HOLD else CallState.CONNECTED
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Failed to toggle hold"
            }
        }
    }
    
    fun setIncomingCall(call: Call) {
        _incomingCall.value = call
        _callState.value = CallState.RINGING
    }
    
    fun clearError() {
        _errorMessage.value = null
    }
}
