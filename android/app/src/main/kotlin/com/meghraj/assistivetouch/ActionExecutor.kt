package com.meghraj.assistivetouch

import android.content.Context
import android.widget.Toast

object ActionExecutor {
    // Single source of truth for translating a string action-ID to a system intent.
    fun execute(context: Context, actionId: String) {
        when (actionId) {
            "home", "back", "recents", "notifications", "power_dialog", "quick_settings" -> {
                val service = AssistiveAccessibilityService.instance
                if (service != null && service.performAction(actionId)) {
                    // Successfully delegated to accessibility layer
                } else {
                    Toast.makeText(context, "Accessibility Service is not enabled.", Toast.LENGTH_SHORT).show()
                }
            }
            "open_menu" -> {
                FloatingService.instance?.openPanel()
            }
            "none" -> {
                // Deliberate no-op
            }
            else -> {
                Toast.makeText(context, "Action: $actionId is unimplemented", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
