# Phase 2 Implementation Plan: Native Android Layer & Bridge

**1. Understand:**
Our goal is to wire the Flutter UI to the native Android ForegroundService capable of rendering `SYSTEM_ALERT_WINDOW` overlays. We need the `FloatingService` to run autonomously alongside the `MainActivity`, persisting through a Notification Channel as mandated by Android 14.

**2. Plan:**
- **Step 1:** Modify `AndroidManifest.xml` to declare the `FloatingService` with `foregroundServiceType="specialUse"`. Include the `PROPERTY_SPECIAL_USE_FGS_SUBTYPE` metadata required for Android 14 Play Store compliance.
- **Step 2:** Write `FloatingService.kt` with a basic Android `Service` implementation that registers a `NotificationChannel` and runs `startForeground()`.
- **Step 3:** Hook up `MainActivity.kt` with the `MethodChannel` logic to process `overlay.start`, `overlay.stop`, and `permissions.getState`.
- **Step 4:** Flesh out `lib/services/overlay_channel.dart` with statically typed wrapper methods for our Flutter UI.

**3. Change:**
(Implementation happening concurrently)
