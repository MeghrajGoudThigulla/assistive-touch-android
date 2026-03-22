package com.meghraj.assistivetouch

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    private val METHOD_CHANNEL = "com.meghraj.assistivetouch/methods"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "overlay.start" -> {
                    val serviceIntent = Intent(this, FloatingService::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(serviceIntent)
                    } else {
                        startService(serviceIntent)
                    }
                    result.success(true)
                }
                "overlay.stop" -> {
                    stopService(Intent(this, FloatingService::class.java))
                    result.success(true)
                }
                "permissions.getState" -> {
                    val overlayGranted = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        Settings.canDrawOverlays(this)
                    } else {
                        true
                    }
                    val state = mapOf(
                        "overlay" to overlayGranted,
                        "accessibility" to false, // TODO: Implement Accessibility status check
                        "deviceAdmin" to false // TODO: Implement DeviceAdmin status check
                    )
                    result.success(state)
                }
                "permissions.openOverlaySettings" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                        val intent = Intent(
                            Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                            Uri.parse("package:$packageName")
                        )
                        startActivity(intent)
                    }
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "com.meghraj.assistivetouch/events").setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    GlobalEventStream.eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    GlobalEventStream.eventSink = null
                }
            }
        )
    }
}
