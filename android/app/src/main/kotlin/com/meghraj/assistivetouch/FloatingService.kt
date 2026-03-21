package com.meghraj.assistivetouch

import android.app.Service
import android.content.Intent
import android.os.IBinder

class FloatingService : Service() {
    companion object {
        const val CHANNEL_ID = "assistive_touch_foreground"
    }
    
    override fun onBind(intent: Intent?): IBinder? = null
}
