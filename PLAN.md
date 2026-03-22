# Phase 2 - Step 2: Overlay UI & Event Channels

**1. Understand:**
With the basic ForegroundService running, the native window overlay currently draws only a temporary blue box. To fulfill the MVP constraints of Phase 2, this Kotlin layer must read Flutter's SharedPreferences directly to apply the user's styled opacity, size, and icon constraints. Additionally, we must wire the `EventChannel` so that the native service can broadcast its real-time lifecycle states (started/stopped) back to the Flutter Home screen.

**2. Plan:**
- **Step 1:** Create `FloatingButtonView.kt`, implementing a native `OnTouchListener`. This class will handle smooth dragging and edge-snapping on the screen using Android's `WindowManager.LayoutParams`.
- **Step 2:** Update `FloatingService.kt` to instantiate `FloatingButtonView` instead of the dummy image. We will query Android's `SharedPreferences` (where Flutter prefixes keys with `flutter.`) to read `flutter.panel_size`, `flutter.panel_opacity`, and `flutter.floating_icon_id`.
- **Step 3:** Introduce `EventChannel` mapping in `MainActivity.kt` and `FloatingService.kt`. The native layer will stream a payload like `{"event": "overlayStateChanged", "running": true}`.
- **Step 4:** Modify `home_screen.dart` to subscribe to the `EventChannel` stream upon load, ensuring the "Service is active" CTA always faithfully matches the true OS service state.

**3. Change:**
(Pending user approval)
