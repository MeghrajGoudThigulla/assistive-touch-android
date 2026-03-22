# Phase 5: Settings Sync & Polish

**1. Understand:**
When you tweak settings like the panel's size or transparency entirely via Flutter sliders, those values persist smoothly to `SharedPreferences`. However, if the native OS `FloatingService` is already running simultaneously, it blindly preserves its original configuration cache. We need to implement a cross-engine pipeline to instantly trigger a redraw of the native layout perfectly matching the Flutter frame. Finally, providing strict `proguard-rules.pro` safeguards Android's compiler from aggressively stripping custom Accessibility Service dependencies during App Bundle releases.

**2. Plan:**
- **Step 1:** Add `"overlay.updateConfig"` listener to `MainActivity.kt` and `overlay_channel.dart`.
- **Step 2:** Write `refreshConfig()` in `FloatingService.kt`. This function intelligently saves the user's `lastX` and `lastY` positioning from the physical touch coordinates, immediately dumps the original overlay memory, and reinstantiates it reading the fresh Flutter configurations dynamically inside an imperceptible sub-frame flicker.
- **Step 3:** Tie `settings_screen.dart` and `customize_icon_screen.dart` into passing those configuration requests directly on `onChangeEnd` completion flags.
- **Step 4:** Build the final `proguard-rules.pro` exclusion file mapping classes safely.

**3. Change:**
(Processed Remotely)
