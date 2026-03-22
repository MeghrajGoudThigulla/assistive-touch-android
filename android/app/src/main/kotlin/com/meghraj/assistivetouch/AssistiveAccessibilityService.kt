package com.meghraj.assistivetouch

import android.accessibilityservice.AccessibilityService
import android.util.Log
import android.view.accessibility.AccessibilityEvent

class AssistiveAccessibilityService : AccessibilityService() {

    companion object {
        var instance: AssistiveAccessibilityService? = null
            private set
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.i("AssistiveAccessibility", "Accessibility Service securely connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        // By design (PRD Principle): We do not monitor UI events or track user behavior.
    }

    override fun onInterrupt() {
        // System interrupt wrapper handle
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        instance = null
        return super.onUnbind(intent)
    }

    fun performAction(actionId: String): Boolean {
        return when (actionId) {
            "home" -> performGlobalAction(GLOBAL_ACTION_HOME)
            "back" -> performGlobalAction(GLOBAL_ACTION_BACK)
            "recents" -> performGlobalAction(GLOBAL_ACTION_RECENTS)
            "notifications" -> performGlobalAction(GLOBAL_ACTION_NOTIFICATIONS)
            "power_dialog" -> performGlobalAction(GLOBAL_ACTION_POWER_DIALOG)
            "quick_settings" -> performGlobalAction(GLOBAL_ACTION_QUICK_SETTINGS)
            "lock_screen" -> if (android.os.Build.VERSION.SDK_INT >= 28) performGlobalAction(8) else false // 8 is GLOBAL_ACTION_LOCK_SCREEN
            "screenshot" -> if (android.os.Build.VERSION.SDK_INT >= 30) performGlobalAction(9) else false // 9 is GLOBAL_ACTION_TAKE_SCREENSHOT
            // Other actions like swipe gestures will map here as needed
            else -> false
        }
    }
}
