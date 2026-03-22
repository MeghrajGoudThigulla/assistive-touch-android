# Phase 4: Device Restrictions & Hardware

**1. Understand:**
To map the remaining actions natively without relying on heavy external Flutter packages, we dive into Android's core hardware subsystems: `AudioManager` (Volume Control), `CameraManager` (Flashlight toggle), and `DevicePolicyManager` (Legacy screen lock fallback). Simultaneously, modern Android provides native Accessibility APIs for screenshots and lock screen interactions, allowing us to leverage our `AssistiveAccessibilityService` cleanly.

**2. Plan:**
- **Step 1:** Establish `DeviceAdminReceiver.kt`. Provide an XML policy that specifically sets `<force-lock />` constraints so Android allows our service to trigger screen shutoff. Register it in `AndroidManifest.xml`.
- **Step 2:** Upgrade `AssistiveAccessibilityService.kt` to securely catch and proxy `"lock_screen"` (`GLOBAL_ACTION_LOCK_SCREEN` on API 28+) and `"screenshot"` (`GLOBAL_ACTION_TAKE_SCREENSHOT` on API 30+).
- **Step 3:** Overhaul `ActionExecutor.kt` to bind `AudioManager` to media volume adjustments, build an internal state tracker for the `CameraManager` toggle to support flashlights natively, and establish the API version fallback sequence if modern global actions fail.

**3. Change:**
(Implementation processed remotely via LLM)
