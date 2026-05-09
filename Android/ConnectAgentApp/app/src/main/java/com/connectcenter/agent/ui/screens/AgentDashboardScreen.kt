package com.connectcenter.agent.ui.screens

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Phone
import androidx.compose.material.icons.filled.PhoneDisabled
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.compose.viewModel
import com.connectcenter.agent.data.repositories.CallRepositoryImpl
import com.connectcenter.agent.domain.entities.Call
import com.connectcenter.agent.domain.entities.CallState
// Importamos todos los casos de uso individuales
import com.connectcenter.agent.domain.usecases.*
import com.connectcenter.agent.viewmodel.CallViewModel

/**
 * Factory manual para construir el CallViewModel inyectando cada
 * uno de los casos de uso que exige su constructor.
 */
val CallViewModelFactory = object : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        val repository = CallRepositoryImpl()

        return CallViewModel(
            acceptCallUseCase = AcceptCallUseCase(repository),
            rejectCallUseCase = RejectCallUseCase(repository),
            endCallUseCase = EndCallUseCase(repository),
            toggleMuteUseCase = ToggleMuteUseCase(repository),
            toggleHoldUseCase = ToggleHoldUseCase(repository)
        ) as T
    }
}

/**
 * Agent dashboard screen showing incoming calls
 */
@Composable
fun AgentDashboardScreen(
    viewModel: CallViewModel = viewModel(factory = CallViewModelFactory)
) {
    // Tus variables actuales
    val incomingCall by viewModel.incomingCall.collectAsState()
    val callState by viewModel.callState.collectAsState()
    // ... las demás variables

    // AGREGAR ESTO: Se ejecuta una sola vez apenas la pantalla se muestra
    LaunchedEffect(Unit) {
        // Ejecutamos la llamada al repositorio en segundo plano (Corrutina)
        kotlinx.coroutines.GlobalScope.launch(kotlinx.coroutines.Dispatchers.IO) {
            val repository = com.connectcenter.agent.data.repositories.AgentRepositoryImpl()
            repository.setAgentStatus("AVAILABLE")
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFFF5F5F5))
    ) {
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(16.dp)
        ) {
            // Header
            Text(
                text = "Agent Dashboard",
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 24.dp)
            )

            // Incoming call card or idle state
            if (incomingCall != null) {
                IncomingCallCard(
                    call = incomingCall!!,
                    callState = callState,
                    callDuration = callDuration,
                    onAccept = { viewModel.acceptCall(incomingCall!!) },
                    onReject = { viewModel.rejectCall(incomingCall!!.contactId) }
                )

                // Call controls (shown after accept)
                if (callState != CallState.RINGING && callState != CallState.IDLE) {
                    Spacer(modifier = Modifier.height(24.dp))

                    CallControlsPanel(
                        isMuted = isMuted,
                        isOnHold = isOnHold,
                        onMuteToggle = { viewModel.toggleMute() },
                        onHoldToggle = { viewModel.toggleHold() },
                        onEndCall = { viewModel.endCall() }
                    )
                }
            } else {
                // Idle state
                IdleStateCard()
            }

            // Error message
            if (!errorMessage.isNullOrEmpty()) {
                Spacer(modifier = Modifier.height(16.dp))
                ErrorMessageCard(
                    message = errorMessage ?: "",
                    onDismiss = { viewModel.clearError() }
                )
            }

            Spacer(modifier = Modifier.weight(1f))

            // Status bar at bottom
            StatusBar(agentStatus = callState)
        }
    }
}

@Composable
fun IncomingCallCard(
    call: Call,
    callState: CallState,
    callDuration: Long,
    onAccept: () -> Unit,
    onReject: () -> Unit
) {
    val statusColor = when (callState) {
        CallState.RINGING -> Color(0xFFFFA500) // Orange
        CallState.CONNECTED -> Color(0xFF4CAF50) // Green
        CallState.MUTED, CallState.ON_HOLD -> Color(0xFFFFD700) // Yellow
        else -> Color(0xFFCCCCCC) // Gray
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .shadow(8.dp, RoundedCornerShape(12.dp))
            .background(Color.White, RoundedCornerShape(12.dp))
    ) {
        Column(
            modifier = Modifier.padding(24.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            // Status indicator
            Box(
                modifier = Modifier
                    .size(80.dp)
                    .background(statusColor, RoundedCornerShape(50)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = Icons.Default.Phone,
                    contentDescription = null,
                    tint = Color.White,
                    modifier = Modifier.size(40.dp)
                )
            }

            Spacer(modifier = Modifier.height(16.dp))

            // Caller name
            Text(
                text = call.callerName,
                style = MaterialTheme.typography.headlineSmall,
                fontWeight = FontWeight.Bold
            )

            // Caller ID
            Text(
                text = call.callerId,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )

            // Call status and duration
            Spacer(modifier = Modifier.height(8.dp))
            Text(
                text = when (callState) {
                    CallState.RINGING -> "Incoming Call..."
                    CallState.CONNECTED -> "Connected • ${formatDuration(callDuration)}"
                    CallState.MUTED -> "Muted • ${formatDuration(callDuration)}"
                    CallState.ON_HOLD -> "On Hold • ${formatDuration(callDuration)}"
                    else -> callState.name
                },
                style = MaterialTheme.typography.bodySmall
            )

            // Action buttons
            AnimatedVisibility(visible = callState == CallState.RINGING) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 24.dp),
                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                ) {
                    // Reject button
                    Button(
                        onClick = onReject,
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFFFF5252)
                        )
                    ) {
                        Icon(
                            imageVector = Icons.Default.PhoneDisabled,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Reject")
                    }

                    // Accept button
                    Button(
                        onClick = onAccept,
                        modifier = Modifier
                            .weight(1f)
                            .height(48.dp),
                        colors = ButtonDefaults.buttonColors(
                            containerColor = Color(0xFF4CAF50)
                        )
                    ) {
                        Icon(
                            imageVector = Icons.Default.Phone,
                            contentDescription = null,
                            modifier = Modifier.size(20.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Accept")
                    }
                }
            }
        }
    }
}

@Composable
fun CallControlsPanel(
    isMuted: Boolean,
    isOnHold: Boolean,
    onMuteToggle: () -> Unit,
    onHoldToggle: () -> Unit,
    onEndCall: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier.padding(16.dp)
        ) {
            Text(
                text = "Call Controls",
                style = MaterialTheme.typography.labelSmall,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 12.dp)
            )

            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 12.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp)
            ) {
                ControlButton(
                    label = if (isMuted) "Unmute" else "Mute",
                    isActive = isMuted,
                    onClick = onMuteToggle,
                    modifier = Modifier.weight(1f)
                )

                ControlButton(
                    label = if (isOnHold) "Resume" else "Hold",
                    isActive = isOnHold,
                    onClick = onHoldToggle,
                    modifier = Modifier.weight(1f)
                )
            }

            Button(
                onClick = onEndCall,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(44.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color(0xFFFF5252)
                )
            ) {
                Icon(
                    imageVector = Icons.Default.PhoneDisabled,
                    contentDescription = null,
                    modifier = Modifier.size(18.dp)
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text("End Call")
            }
        }
    }
}

@Composable
fun ControlButton(
    label: String,
    isActive: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Button(
        onClick = onClick,
        modifier = modifier.height(44.dp),
        colors = ButtonDefaults.buttonColors(
            containerColor = if (isActive) Color(0xFF2196F3) else Color(0xFFE0E0E0)
        )
    ) {
        Text(
            text = label,
            color = if (isActive) Color.White else Color.Black,
            style = MaterialTheme.typography.labelSmall
        )
    }
}

@Composable
fun IdleStateCard() {
    Card(
        modifier = Modifier.fillMaxWidth()
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(32.dp),
            horizontalAlignment = Alignment.CenterHorizontally
        ) {
            Icon(
                imageVector = Icons.Default.Phone,
                contentDescription = null,
                modifier = Modifier
                    .size(64.dp)
                    .padding(bottom = 16.dp),
                tint = MaterialTheme.colorScheme.primary
            )

            Text(
                text = "Ready to Receive Calls",
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.padding(bottom = 8.dp)
            )

            Text(
                text = "Waiting for incoming calls...",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

@Composable
fun ErrorMessageCard(
    message: String,
    onDismiss: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .background(Color(0xFFFFEBEE), RoundedCornerShape(8.dp))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(16.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = message,
                color = Color(0xFFC62828),
                style = MaterialTheme.typography.bodySmall,
                modifier = Modifier.weight(1f)
            )

            Button(
                onClick = onDismiss,
                modifier = Modifier.size(32.dp),
                colors = ButtonDefaults.buttonColors(
                    containerColor = Color.Transparent
                )
            ) {
                Text("✕", color = Color(0xFFC62828))
            }
        }
    }
}

@Composable
fun StatusBar(agentStatus: CallState) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                Color(0xFFF5F5F5),
                RoundedCornerShape(8.dp)
            )
            .padding(12.dp),
        horizontalArrangement = Arrangement.SpaceBetween,
        verticalAlignment = Alignment.CenterVertically
    ) {
        Text(
            text = "Status:",
            style = MaterialTheme.typography.labelSmall,
            fontWeight = FontWeight.Bold
        )

        val statusText = when (agentStatus) {
            CallState.IDLE -> "Available"
            CallState.RINGING -> "Incoming Call"
            CallState.CONNECTED -> "In Call"
            CallState.MUTED -> "Muted"
            CallState.ON_HOLD -> "On Hold"
            else -> agentStatus.name
        }

        val statusColor = when (agentStatus) {
            CallState.IDLE -> Color(0xFF4CAF50)
            CallState.RINGING -> Color(0xFFFFA500)
            CallState.CONNECTED -> Color(0xFF4CAF50)
            else -> Color(0xFF9E9E9E)
        }

        Box(
            modifier = Modifier
                .size(12.dp)
                .background(statusColor, RoundedCornerShape(50))
        )

        Text(
            text = statusText,
            style = MaterialTheme.typography.labelSmall,
            color = statusColor,
            fontWeight = FontWeight.Bold
        )
    }
}

private fun formatDuration(seconds: Long): String {
    val mins = seconds / 60
    val secs = seconds % 60
    return "%02d:%02d".format(mins, secs)
}