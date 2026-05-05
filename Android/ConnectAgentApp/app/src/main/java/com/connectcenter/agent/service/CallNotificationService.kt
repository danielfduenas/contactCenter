package com.connectcenter.agent.service

import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import com.connectcenter.agent.MainActivity
import com.connectcenter.agent.R

/**
 * Firebase Cloud Messaging Service for receiving incoming call notifications
 */
class CallNotificationService : FirebaseMessagingService() {
    
    override fun onMessageReceived(remoteMessage: RemoteMessage) {
        super.onMessageReceived(remoteMessage)
        
        // Extract call data from notification
        val callerId = remoteMessage.data["caller_id"] ?: "Unknown"
        val callerName = remoteMessage.data["caller_name"] ?: "Support Request"
        val contactId = remoteMessage.data["contact_id"] ?: ""
        
        // Show incoming call notification
        showIncomingCallNotification(callerName, callerId, contactId)
    }
    
    override fun onNewToken(token: String) {
        super.onNewToken(token)
        
        // Send token to server for push notification registration
        // TODO: Store FCM token in AWS for this agent
        sendTokenToServer(token)
    }
    
    private fun showIncomingCallNotification(
        callerName: String,
        callerId: String,
        contactId: String
    ) {
        val notificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        
        // Create notification actions
        val acceptIntent = Intent(this, CallNotificationBroadcastReceiver::class.java).apply {
            action = ACTION_ACCEPT_CALL
            putExtra("contact_id", contactId)
            putExtra("caller_name", callerName)
        }
        
        val rejectIntent = Intent(this, CallNotificationBroadcastReceiver::class.java).apply {
            action = ACTION_REJECT_CALL
            putExtra("contact_id", contactId)
        }
        
        val acceptPendingIntent = PendingIntent.getBroadcast(
            this,
            ACCEPT_REQUEST_CODE,
            acceptIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        val rejectPendingIntent = PendingIntent.getBroadcast(
            this,
            REJECT_REQUEST_CODE,
            rejectIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Create pending intent for tapping notification
        val mainActivityIntent = Intent(this, MainActivity::class.java).apply {
            putExtra("contact_id", contactId)
            putExtra("incoming_call", true)
        }
        
        val mainPendingIntent = PendingIntent.getActivity(
            this,
            0,
            mainActivityIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        // Build notification
        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setSmallIcon(R.drawable.ic_incoming_call)
            .setContentTitle("Incoming Call")
            .setContentText(callerName)
            .setContentIntent(mainPendingIntent)
            .setPriority(NotificationCompat.PRIORITY_MAX)
            .setCategory(NotificationCompat.CATEGORY_CALL)
            .setAutoCancel(true)
            .setFullScreenIntent(mainPendingIntent, true)
            .addAction(
                R.drawable.ic_accept_call,
                "Accept",
                acceptPendingIntent
            )
            .addAction(
                R.drawable.ic_reject_call,
                "Reject",
                rejectPendingIntent
            )
            .build()
        
        notificationManager.notify(NOTIFICATION_ID, notification)
    }
    
    private fun sendTokenToServer(token: String) {
        // TODO: Send FCM token to backend to register this device
        // This is called when:
        // 1. App first starts
        // 2. FCM token is refreshed
        // 3. App is reinstalled
    }
    
    companion object {
        const val CHANNEL_ID = "incoming_calls"
        const val NOTIFICATION_ID = 123
        const val ACTION_ACCEPT_CALL = "com.connectcenter.ACCEPT_CALL"
        const val ACTION_REJECT_CALL = "com.connectcenter.REJECT_CALL"
        const val ACCEPT_REQUEST_CODE = 100
        const val REJECT_REQUEST_CODE = 101
    }
}
