# Phase 3 - Actions & Gestures

**1. Understand:**
To execute powerful, global system commands (like navigating Home, Back, Recents, or dropping the Notification shade), Android mandates an `AccessibilityService`. The PRD places strict constraints on this service—specifically `canRetrieveWindowContent="false"`—guaranteeing no screen observation can technically occur, validating our core privacy pledge. We also need a strong routing object to digest string tokens into actions.

**2. Plan:**
- **Step 1:** Implement `AssistiveAccessibilityService.kt`. It extends Android's native `AccessibilityService` but completely omits event tracking, only exposing robust bindings to `performGlobalAction()`.
- **Step 2:** Write `res/xml/accessibility_service_config.xml` strictly deploying the PRD's exact XML metadata structure and referencing an exact `strings.xml` description to pass Play Store checks.
- **Step 3:** Implement `ActionExecutor.kt` as an object router. When the Floating Button is tapped, it invokes `ActionExecutor.execute("open_menu")`. When a system action is invoked, it delegates to the Accessibility Service.
- **Step 4:** Upgrade `AndroidManifest.xml` so the Play Console crawler appropriately recognizes the secure `.xml` configurations.
- **Step 5:** Bind `FloatingButtonView.kt` to dynamically read the single-tap gesture config from Flutter's storage, defaulting to `"open_menu"`.

**3. Change:**
Executing now.
