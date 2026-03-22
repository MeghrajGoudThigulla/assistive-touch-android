# Android Assistive Touch Service

# Android Assistive Touch Service Module

This document provides a technical overview of the native Android module responsible for the Assistive Touch overlay feature. It is intended for developers who need to understand, maintain, or extend its functionality.

## 1. Overview

The Assistive Touch Service module implements a system-wide floating overlay that provides users with quick access to common system actions. It is designed to run persistently in the background, drawing over other applications to ensure the floating button is always available.

The module consists of three main parts:
1.  **UI Layer**: Manages the floating button and the main action panel that appears when the button is tapped.
2.  **Service Layer**: A foreground Android `Service` that ensures the UI persists even when the main application is closed.
3.  **Action Execution Layer**: A central dispatcher that translates user actions into calls to the appropriate Android system APIs, primarily leveraging an `AccessibilityService` for privileged operations.

## 2. Core Components

The module's logic is distributed across several key classes, each with a distinct responsibility.

### `FloatingService`
This is the heart of the module. As a foreground `Service`, it has a persistent notification that keeps it alive and informs the user that it's running.

**Responsibilities:**
*   **Lifecycle Management**: Manages the creation and destruction of the overlay UI. It uses the `WindowManager` to add and remove views from the screen.
*   **State Management**: It is the singleton entry point (`FloatingService.instance`) for controlling the UI state. It handles opening the main panel (`openPanel()`) and closing it (`closePanel()`).
*   **Configuration Changes**: The `refreshConfig()` method allows the service to be re-initialized with new settings (e.g., button size, opacity) sent from the Flutter layer, by destroying and recreating the `FloatingButtonView`.
*   **Communication**: Uses `GlobalEventStream` to send lifecycle events (e.g., `overlayStateChanged`) back to the Flutter application.

### `ActionExecutor`
This is a singleton object that acts as the central "brain" for all user-initiated actions. It decouples the UI from the implementation of the actions themselves.

**Responsibilities:**
*   **Action Routing**: The `execute(context, actionId)` method takes a simple string identifier (e.g., `"home"`, `"volume_up"`) and maps it to the correct system call.
*   **Delegation**: It determines the best way to perform an action. For privileged system navigation, it delegates to `AssistiveAccessibilityService`. For hardware control like the flashlight, it uses `CameraManager`. For volume, it uses `AudioManager`.
*   **Fallback Logic**: Implements fallback mechanisms for critical functions. For example, the `lock_screen` action first attempts to use the modern `AccessibilityService` global action, and if that fails or is unavailable, it falls back to using the `DevicePolicyManager`.

The following diagram illustrates the dispatch logic within `ActionExecutor`:

```mermaid
graph TD
    A[User Taps UI<br>(FloatingButtonView/PanelOverlayView)] --> B{ActionExecutor.execute(actionId)};
    B --> C[Accessibility Actions<br><i>home, back, recents...</i>];
    C --> D[AssistiveAccessibilityService];
    B --> E[Direct System APIs<br><i>volume_up, flashlight...</i>];
    E --> F[AudioManager / CameraManager];
    B --> G[UI Actions<br><i>open_menu</i>];
    G --> H[FloatingService];
```

### `FloatingButtonView`
This custom `View` is the draggable floating button that is always visible on the screen.

**Responsibilities:**
*   **Gesture Detection**: Uses a `GestureDetector` to distinguish between `onSingleTapConfirmed`, `onDoubleTap`, and `onLongPress`.
*   **Drag and Snap**: Implements touch listeners (`ACTION_DOWN`, `ACTION_MOVE`, `ACTION_UP`) to allow the user to drag the button around the screen. On release (`ACTION_UP`), it triggers a `snapToEdge()` animation to move the button cleanly to the nearest vertical edge.
*   **Action Invocation**: Based on the detected gesture, it retrieves the corresponding action ID from `SharedPreferences` and calls `ActionExecutor.execute()`.
*   **Configuration**: Reads its appearance (size, opacity, icon) from `SharedPreferences`, which are set by the Flutter UI.

### `PanelOverlayView`
This custom `View` is the main action panel that appears when the user taps the floating button.

**Responsibilities:**
*   **UI Layout**: Renders a modal overlay with a `GridLayout` of action icons. The panel is paginated, allowing for more actions than can fit on a single screen.
*   **Action Binding**: Each icon in the grid is bound to a specific `actionId`. When an icon is tapped, it invokes `ActionExecutor.execute()` with its ID and then calls its `onClose` callback to signal the `FloatingService` to dismiss the panel.
*   **Self-Contained**: The view handles its own rendering, including the pagination dots, and consumes all touch events within its bounds to prevent interaction with the underlying application.

### `AssistiveAccessibilityService`
This is a critical component for executing privileged system actions. Android grants `AccessibilityService` the ability to perform global actions that are normally restricted.

**Responsibilities:**
*   **Perform Global Actions**: The `performAction(actionId)` method maps string identifiers to `AccessibilityService` constants like `GLOBAL_ACTION_HOME`, `GLOBAL_ACTION_BACK`, and `GLOBAL_ACTION_RECENTS`.
*   **Singleton Access**: It maintains a static `instance` of itself, which `ActionExecutor` uses to dispatch commands. This avoids complex binding or context passing.
*   **Privacy-Focused**: The implementation of `onAccessibilityEvent` is intentionally empty. The service does not monitor or react to UI events, respecting user privacy.

## 3. Execution Flow: From Tap to Action

Understanding the flow of control from a user tap to a system action is key to working with this module.

**Scenario: User opens the panel and taps "Home".**

1.  **Tap Floating Button**: The user performs a single tap on `FloatingButtonView`.
2.  **Gesture Detected**: The view's `onSingleTapConfirmed` method is triggered. It reads the configured action for a single tap, which defaults to `"open_menu"`.
3.  **Execute "open_menu"**: `FloatingButtonView` calls `ActionExecutor.execute(context, "open_menu")`.
4.  **Open Panel**: `ActionExecutor` routes this action to `FloatingService.instance.openPanel()`.
5.  **UI State Change**: `FloatingService` hides `FloatingButtonView` and adds a new `PanelOverlayView` to the `WindowManager`. The panel is now visible.
6.  **Tap "Home" Icon**: The user taps the "Home" icon inside the `PanelOverlayView`.
7.  **Execute "home"**: The `onClickListener` for the "Home" icon calls `ActionExecutor.execute(context, "home")`.
8.  **Delegate to Accessibility**: `ActionExecutor` routes the `"home"` action to `AssistiveAccessibilityService.instance.performAction("home")`.
9.  **Perform Global Action**: The accessibility service calls the system's `performGlobalAction(GLOBAL_ACTION_HOME)`. The OS navigates to the home screen.
10. **Close Panel**: Concurrently, the icon's `onClickListener` in `PanelOverlayView` calls its `onClose` callback, which triggers `FloatingService.closePanel()`.
11. **UI State Restored**: `FloatingService` removes the `PanelOverlayView` and makes `FloatingButtonView` visible again.

## 4. Configuration and Flutter Integration

The native Android module is designed to be controlled by the main Flutter application.

*   **Configuration via SharedPreferences**: The `FloatingButtonView` and other components read their settings directly from `SharedPreferences`. The keys are prefixed with `flutter.` (e.g., `flutter.panel_size`, `flutter.gesture.doubleTap`), indicating that the Flutter `shared_preferences` plugin is the source of truth for these values.
*   **Events to Flutter**: The `GlobalEventStream` object provides a simple bridge for sending data from the native side back to Flutter. It holds an `EventChannel.EventSink`. `FloatingService` uses this to notify the Flutter app about its running state, allowing the UI to reflect whether the overlay is active.

## 5. Permissions and Fallbacks

Executing system-level actions requires special permissions, which are handled gracefully.

*   **Accessibility Service**: This is the primary mechanism for actions like Home, Back, Recents, Notifications, Power Dialog, Screenshot, and Lock Screen (on Android P+). The user must explicitly enable this service in the device's settings. The app should provide a clear path for the user to do so.
*   **Device Admin**: This is used as a **fallback only** for the "Lock Screen" action on older Android versions or if the accessibility service method fails. It requires a separate, more sensitive permission. The `DeviceAdminReceiver` class handles the callbacks for when this permission is enabled or disabled.
*   **Draw Over Other Apps**: The `FloatingService` requires the "Draw over other apps" permission to add views to the `WindowManager`.

## 6. Placeholder Components

The following files are currently included but contain no logic. They may be placeholders for future functionality.

*   `BatteryMonitor.kt`
*   `OverlayController.kt`