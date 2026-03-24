package com.meghraj.assistivetouch

import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.hardware.camera2.CameraManager
import android.media.AudioManager
import android.os.Build
import android.widget.Toast

object ActionExecutor {
    private var isFlashlightOn = false
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
            "volume_up" -> {
                val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_RAISE, AudioManager.FLAG_SHOW_UI)
            }
            "volume_down" -> {
                val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
                audioManager.adjustStreamVolume(AudioManager.STREAM_MUSIC, AudioManager.ADJUST_LOWER, AudioManager.FLAG_SHOW_UI)
            }
            "lock_screen" -> {
                val service = AssistiveAccessibilityService.instance
                var locked = false
                if (Build.VERSION.SDK_INT >= 28 && service != null) {
                    locked = service.performAction("lock_screen")
                }
                if (!locked) {
                    try {
                        val dpm = context.getSystemService(Context.DEVICE_POLICY_SERVICE) as DevicePolicyManager
                        val compName = ComponentName(context, DeviceAdminReceiver::class.java)
                        if (dpm.isAdminActive(compName)) {
                            dpm.lockNow()
                        } else {
                            Toast.makeText(context, "Device Admin not enabled for locking fallback.", Toast.LENGTH_SHORT).show()
                        }
                    } catch (e: Exception) {
                        Toast.makeText(context, "Lock screen failed.", Toast.LENGTH_SHORT).show()
                    }
                }
            }
            "flashlight" -> {
                try {
                    val cameraManager = context.getSystemService(Context.CAMERA_SERVICE) as CameraManager
                    val cameraId = cameraManager.cameraIdList[0]
                    isFlashlightOn = !isFlashlightOn
                    cameraManager.setTorchMode(cameraId, isFlashlightOn)
                } catch (e: Exception) {
                    Toast.makeText(context, "Flashlight unavailable", Toast.LENGTH_SHORT).show()
                }
            }
            "screenshot" -> {
                val service = AssistiveAccessibilityService.instance
                if (Build.VERSION.SDK_INT >= 30 && service != null) {
                    service.performAction("screenshot")
                } else {
                    Toast.makeText(context, "Screenshot requires Android 11+ Accessibility permissions.", Toast.LENGTH_SHORT).show()
                }
            }
            "open_menu" -> {
                FloatingService.instance?.openPanel()
            }
            "open_settings" -> {
                val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
                launchIntent?.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
                context.startActivity(launchIntent)
                FloatingService.instance?.closePanel()
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
