package com.connectcenter.agent.ui.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.connectcenter.agent.ui.screens.LoginScreen
import com.connectcenter.agent.ui.screens.AgentDashboardScreen

/**
 * Navigation routes
 */
object NavRoutes {
    const val LOGIN = "login"
    const val DASHBOARD = "dashboard"
}

/**
 * App navigation setup
 */
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    
    NavHost(
        navController = navController,
        startDestination = NavRoutes.LOGIN
    ) {
        composable(NavRoutes.LOGIN) {
            LoginScreen(
                onLoginSuccess = {
                    navController.navigate(NavRoutes.DASHBOARD) {
                        popUpTo(NavRoutes.LOGIN) { inclusive = true }
                    }
                }
            )
        }
        
        composable(NavRoutes.DASHBOARD) {
            AgentDashboardScreen()
        }
    }
}
