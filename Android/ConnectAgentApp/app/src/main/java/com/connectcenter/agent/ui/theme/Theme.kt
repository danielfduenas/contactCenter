package com.connectcenter.agent.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val LightColors = lightColorScheme(
    primary = Color(0xFF2196F3),
    secondary = Color(0xFF03DAC6),
    tertiary = Color(0xFF03DAC6),
    background = Color(0xFFFAFAFA),
    surface = Color.White,
    error = Color(0xFFB00020)
)

private val DarkColors = darkColorScheme(
    primary = Color(0xFF64B5F6),
    secondary = Color(0xFF03DAC6),
    tertiary = Color(0xFF03DAC6),
    background = Color(0xFF121212),
    surface = Color(0xFF1E1E1E),
    error = Color(0xFFCF6679)
)

@Composable
fun ConnectAgentAppTheme(
    darkTheme: Boolean = false,
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColors else LightColors
    
    MaterialTheme(
        colorScheme = colorScheme,
        typography = androidx.compose.material3.Typography(),
        content = content
    )
}
