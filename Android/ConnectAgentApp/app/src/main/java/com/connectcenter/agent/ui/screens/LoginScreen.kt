package com.connectcenter.agent.ui.screens

import android.content.Context
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.compose.viewModel
import com.connectcenter.agent.data.repositories.AuthRepositoryImpl
import com.connectcenter.agent.domain.usecases.*
import com.connectcenter.agent.viewmodel.AuthViewModel

/**
 * Factory manual modificado para recibir el Context de Android
 * y así poder instanciar SharedPreferences.
 */
class AuthViewModelFactory(private val context: Context) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        // 1. Obtenemos las SharedPreferences nativas
        val sharedPreferences = context.getSharedPreferences("agent_session", Context.MODE_PRIVATE)

        // 2. Armamos el repositorio pasándole las preferencias
        val repository = AuthRepositoryImpl(sharedPreferences)

        // 3. Inyectamos los casos de uso individuales (como hicimos en el Dashboard)
        // Nota: Si tus clases terminan en "UC" (ej. LoginUC), cámbialo aquí abajo.
        return AuthViewModel(
            loginUseCase = LoginUseCase(repository),
            logoutUseCase = LogoutUseCase(repository),
            checkSessionUseCase = CheckSessionUseCase(repository)
        ) as T
    }
}

/**
 * Login screen for agent authentication
 */
@Composable
fun LoginScreen(
    onLoginSuccess: () -> Unit
) {
    // Extraemos el contexto nativo de Android desde Compose
    val context = LocalContext.current

    // Instanciamos el ViewModel usando nuestra fábrica con el contexto
    val viewModel: AuthViewModel = viewModel(
        factory = AuthViewModelFactory(context)
    )

    var username by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var passwordVisible by remember { mutableStateOf(false) }

    val isLoading by viewModel.isLoading.collectAsState()
    val errorMessage by viewModel.errorMessage.collectAsState()
    val sessionState by viewModel.sessionState.collectAsState()

    // Navigate on successful login
    LaunchedEffect(sessionState) {
        if (sessionState?.isAuthenticated == true) {
            onLoginSuccess()
        }
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.Center,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Logo/Title
        Text(
            text = "Agent Portal",
            style = MaterialTheme.typography.headlineLarge,
            modifier = Modifier.padding(bottom = 32.dp)
        )

        // Username field
        OutlinedTextField(
            value = username,
            onValueChange = { username = it },
            label = { Text("Username") },
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 16.dp),
            enabled = !isLoading,
            singleLine = true
        )

        // Password field
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 24.dp),
            enabled = !isLoading,
            singleLine = true,
            visualTransformation = if (passwordVisible) {
                VisualTransformation.None
            } else {
                PasswordVisualTransformation()
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Password),
            trailingIcon = {
                val image = if (passwordVisible) {
                    Icons.Default.Visibility
                } else {
                    Icons.Default.VisibilityOff
                }

                IconButton(
                    onClick = { passwordVisible = !passwordVisible },
                    enabled = !isLoading
                ) {
                    Icon(imageVector = image, contentDescription = null)
                }
            }
        )

        // Error message
        if (!errorMessage.isNullOrEmpty()) {
            Text(
                text = errorMessage ?: "",
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp)
            )
        }

        // Login button
        Button(
            onClick = { viewModel.login(username, password) },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            enabled = !isLoading && username.isNotEmpty() && password.isNotEmpty()
        ) {
            if (isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Text("Login")
            }
        }

        // Info text
        Text(
            text = "Use your Amazon Connect credentials",
            modifier = Modifier.padding(top = 16.dp),
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}