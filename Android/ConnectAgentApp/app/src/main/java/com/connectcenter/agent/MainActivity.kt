package com.connectcenter.agent

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.connectcenter.agent.ui.navigation.AppNavigation
import com.connectcenter.agent.ui.theme.ConnectAgentAppTheme

/**
 * Main activity
 */
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        setContent {
            ConnectAgentAppTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    AppNavigation()
                }
            }
        }
        
        // Handle incoming call from notification
        val incomingCall = intent.getBooleanExtra("incoming_call", false)
        if (incomingCall) {
            val contactId = intent.getStringExtra("contact_id") ?: ""
            val callerName = intent.getStringExtra("caller_name") ?: ""
            // TODO: Pass this data to CallViewModel to show incoming call
        }
    }
}
