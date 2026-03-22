package com.meghraj.assistivetouch

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.graphics.PixelFormat
import android.os.Build
import android.os.IBinder
import android.view.Gravity
import android.view.WindowManager
import android.widget.FrameLayout
import android.widget.ImageView
import androidx.core.app.NotificationCompat
import android.annotation.SuppressLint

class FloatingService : Service() {
    companion object {
        const val CHANNEL_ID = "assistive_touch_foreground"
        const val NOTIFICATION_ID = 101
        @SuppressLint("StaticFieldLeak")
        var instance: FloatingService? = null
            private set
    }
    
    private var windowManager: WindowManager? = null
    private var floatingView: FrameLayout? = null
    private var panelView: PanelOverlayView? = null

    override fun onCreate() {
        super.onCreate()
        instance = this
        createNotificationChannel()
        val notification = createNotification()
        startForeground(NOTIFICATION_ID, notification)
        
        initializeOverlay()

        GlobalEventStream.sendEvent(mapOf(
            "event" to "overlayStateChanged",
            "running" to true
        ))
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        // Keeps the service sticky so it restarts gracefully if Android cleans up memory
        return START_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? = null

    override fun onDestroy() {
        super.onDestroy()
        cleanupOverlay()
        closePanel()
        instance = null

        GlobalEventStream.sendEvent(mapOf(
            "event" to "overlayStateChanged",
            "running" to false
        ))
    }

    private fun initializeOverlay() {
        windowManager = getSystemService(Context.WINDOW_SERVICE) as WindowManager

        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.WRAP_CONTENT,
            WindowManager.LayoutParams.WRAP_CONTENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE or WindowManager.LayoutParams.FLAG_LOCAL_FOCUS_MODE,
            PixelFormat.TRANSLUCENT
        ).apply {
            gravity = Gravity.TOP or Gravity.START
            x = 0
            y = 500
        }

        floatingView = FloatingButtonView(this, windowManager!!, params)

        windowManager?.addView(floatingView, params)
    }

    private fun cleanupOverlay() {
        floatingView?.let { view ->
            windowManager?.removeView(view)
        }
        floatingView = null
    }

    fun openPanel() {
        if (panelView != null) return
        val layoutFlag = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY
        } else {
            @Suppress("DEPRECATION")
            WindowManager.LayoutParams.TYPE_PHONE
        }

        val params = WindowManager.LayoutParams(
            WindowManager.LayoutParams.MATCH_PARENT,
            WindowManager.LayoutParams.MATCH_PARENT,
            layoutFlag,
            WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE,
            PixelFormat.TRANSLUCENT
        )

        panelView = PanelOverlayView(this) { closePanel() }
        windowManager?.addView(panelView, params)
        floatingView?.visibility = android.view.View.GONE
    }

    fun closePanel() {
        panelView?.let { view ->
            windowManager?.removeView(view)
        }
        panelView = null
        floatingView?.visibility = android.view.View.VISIBLE
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Assistive Touch Status",
                NotificationManager.IMPORTANCE_LOW
            ).apply {
                description = "Keeps the assistive touch overlay active"
            }
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }

    private fun createNotification(): Notification {
        return NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Assistive Touch")
            .setContentText("Tap to open settings")
            .setSmallIcon(android.R.drawable.ic_menu_edit) 
            .setPriority(NotificationCompat.PRIORITY_LOW)
            .build()
    }
}
