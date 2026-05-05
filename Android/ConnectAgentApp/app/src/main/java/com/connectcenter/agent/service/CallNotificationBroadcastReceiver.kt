package com.connectcenter.agent.service

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import com.connectcenter.agent.MainActivity

/**
 * Broadcast receiver for handling notification actions
 */
class CallNotificationBroadcastReceiver : BroadcastReceiver() {
    
    override fun onReceive(context: Context?, intent: Intent?) {
        if (context == null || intent == null) return
        
        val contactId = intent.getStringExtra("contact_id") ?: return
        val callerName = intent.getStringExtra("caller_name") ?: "Caller"
        
        when (intent.action) {
            CallNotificationService.ACTION_ACCEPT_CALL -> {
                acceptCall(context, contactId, callerName)
            }
            CallNotificationService.ACTION_REJECT_CALL -> {
                rejectCall(context, contactId)
            }
        }
    }
    
    private fun acceptCall(context: Context, contactId: String, callerName: String) {
        // Launch MainActivity with call accepted
        val mainIntent = Intent(context, MainActivity::class.java).apply {
            action = "ACCEPT_CALL"
            putExtra("contact_id", contactId)
            putExtra("caller_name", callerName)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
        }
        context.startActivity(mainIntent)
        
        // TODO: Call acceptCall use case
    }
    
    private fun rejectCall(context: Context, contactId: String) {
        // TODO: Call rejectCall use case
        
        // Remove notification
        val notificationManager =
            context.getSystemService(Context.NOTIFICATION_SERVICE) as android.app.NotificationManager
        notificationManager.cancel(CallNotificationService.NOTIFICATION_ID)
    }
}
