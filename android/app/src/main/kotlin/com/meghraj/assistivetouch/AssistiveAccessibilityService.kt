package com.meghraj.assistivetouch

import android.accessibilityservice.AccessibilityService
import android.view.accessibility.AccessibilityEvent

class AssistiveAccessibilityService : AccessibilityService() {
    override fun onAccessibilityEvent(event: AccessibilityEvent?) {}
    override fun onInterrupt() {}
}
