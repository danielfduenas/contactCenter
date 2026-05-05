package com.connectcenter.agent.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.connectcenter.agent.domain.entities.SessionState
import com.connectcenter.agent.domain.usecases.LoginUseCase
import com.connectcenter.agent.domain.usecases.LogoutUseCase
import com.connectcenter.agent.domain.usecases.CheckSessionUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

/**
 * ViewModel for authentication
 */
class AuthViewModel(
    private val loginUseCase: LoginUseCase,
    private val logoutUseCase: LogoutUseCase,
    private val checkSessionUseCase: CheckSessionUseCase
) : ViewModel() {
    
    private val _sessionState = MutableStateFlow<SessionState?>(null)
    val sessionState: StateFlow<SessionState?> = _sessionState.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()
    
    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()
    
    init {
        checkSession()
    }
    
    fun login(username: String, password: String) {
        viewModelScope.launch {
            _isLoading.value = true
            _errorMessage.value = null
            
            val result = loginUseCase(username, password)
            
            result.onSuccess { session ->
                _sessionState.value = session
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Login failed"
            }
            
            _isLoading.value = false
        }
    }
    
    fun logout() {
        viewModelScope.launch {
            val result = logoutUseCase()
            result.onSuccess {
                _sessionState.value = null
            }.onFailure { error ->
                _errorMessage.value = error.message ?: "Logout failed"
            }
        }
    }
    
    private fun checkSession() {
        viewModelScope.launch {
            val isValid = checkSessionUseCase()
            if (isValid) {
                // Session is still valid, load it
                // TODO: Implement session loading
            }
        }
    }
    
    fun clearError() {
        _errorMessage.value = null
    }
}
