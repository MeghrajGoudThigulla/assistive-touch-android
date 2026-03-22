# Flutter Application

Here is the technical documentation for the Flutter Application module.

***

## Flutter Application Module Documentation

### 1. Overview

This document describes the Flutter portion of the Assistive Touch application. The Flutter module serves as the user-facing interface for configuring and controlling the native Android overlay service. Its primary responsibilities are:

*   **Onboarding:** Guiding new users through language selection and necessary permission grants.
*   **Service Control:** Providing a simple interface on the `HomeScreen` to start and stop the overlay service.
*   **Configuration:** Allowing users to customize the appearance and behavior of the floating icon and its associated panel.
*   **State Synchronization:** Persisting user settings and reflecting the real-time state of the native service.

The entire UI is built with a consistent dark theme, defined in `main.dart`, and uses a shared `AppScaffold` widget for a uniform look and feel across all screens.

### 2. Core Concepts

#### 2.1. State Management via SharedPreferences

The application uses the `shared_preferences` package for simple, persistent key-value storage. This is the single source of truth for all user settings and onboarding progress.

Key flags stored include:
*   `has_selected_language`: Tracks if the user has completed the initial language selection.
*   `onboarding_completed`: Tracks if the user has granted the "display over other apps" permission.
*   `floating_icon_id`, `panel_opacity`, `panel_size`, etc.: User-configurable settings from `CustomizeIconScreen` and `SettingsScreen`.

#### 2.2. Native Communication: The OverlayChannel

The bridge between the Flutter UI and the native Android service is the `OverlayChannel` (`lib/services/overlay_channel.dart`). This class abstracts all platform channel communication.

*   **MethodChannel (`com.meghraj.assistivetouch/methods`):** Used by Flutter to invoke actions on the native side. This is a one-way call from Flutter to native code (e.g., "start the service," "update your configuration").
*   **EventChannel (`com.meghraj.assistivetouch/events`):** Used by the native side to broadcast events to Flutter. This allows the native service to proactively send state updates to the UI (e.g., "the service has started/stopped"). The `HomeScreen` subscribes to `OverlayChannel.overlayEvents` to keep its UI in sync.

This separation allows the UI to be a "dumb" configuration panel while the complex logic of managing an overlay window resides in the native layer.

### 3. Application Startup & Onboarding Flow

The application's entry point is the `main()` function in `lib/main.dart`. It immediately checks `SharedPreferences` to determine the user's progress and sets the `initialRoute` accordingly. This ensures users are always directed to the correct screen, whether they are a new user or a returning one.

The onboarding flow is a linear progression from language selection to permission granting before the user reaches the main home screen.

```mermaid
graph TD
    A[App Start] --> B{Check SharedPreferences};
    B -- has_selected_language is false --> C[/language];
    B -- onboarding_completed is false --> D[/permissions];
    B -- Both are true --> E[/home];
    C[LanguageSelectionScreen] --> F[Save Language Pref];
    F --> D[PermissionGuidanceScreen];
    D --> G{User Grants Permission in OS Settings};
    G -- Returns to App --> H[Save Onboarding Pref];
    H --> E[HomeScreen];
```

### 4. Key Components & Screens

#### 4.1. Onboarding Screens

*   **`LanguageSelectionScreen`**: The first screen for new users. It saves the `has_selected_language` flag and navigates to the `PermissionGuidanceScreen`. The language choice itself is saved but not yet used for localization.
*   **`PermissionGuidanceScreen`**: This screen explains the need for the "display over other apps" permission.
    *   It uses `OverlayChannel.openOverlaySettings()` to direct the user to the relevant system settings page.
    *   It implements `WidgetsBindingObserver` to listen for when the app is resumed. The `didChangeAppLifecycleState` callback triggers `_checkIfGrantedAutomatically`, which verifies the permission status and, upon success, sets the `onboarding_completed` flag and navigates the user to the `/home` route.

#### 4.2. Main Application Screens

*   **`HomeScreen`**: The application's main dashboard.
    *   **Service Control:** The primary "Start/Stop" button calls `_toggleService`. This function checks for permissions before attempting to start the service via `OverlayChannel.startOverlay()`.
    *   **State Listening:** In `initState`, it subscribes to the `OverlayChannel.overlayEvents` stream. This allows the UI to reactively update the `_isServiceRunning` state if the service is started or stopped from outside the app (e.g., by the OS).
    *   **Navigation:** Provides `ListTile` buttons to navigate to the customization and settings screens.

*   **`SettingsScreen`**: Allows configuration of the floating icon's behavior and appearance.
    *   **Loading:** In `initState`, `_loadSettings` fetches current values from `SharedPreferences`.
    *   **Saving:** When a user changes a setting (e.g., adjusts the `Panel Opacity` slider), the new value is immediately saved to `SharedPreferences`.
    *   **Notifying Native Layer:** Crucially, after saving, `OverlayChannel.updateConfig()` is called. This signals the native service to re-read its configuration from `SharedPreferences` and apply the changes in real-time without needing a service restart.

*   **`CustomizeIconScreen`**: Similar to the settings screen, but focused on the icon's visual style.
    *   The `_saveIcon` method persists the selected icon's ID to `SharedPreferences` and calls `OverlayChannel.updateConfig()` to update the live overlay icon.

*   **`CustomizePanelScreen`**: This screen is currently a **UI prototype**. It displays a `PageView` with two static grids representing the panel layout. The logic for reassigning actions and saving the panel configuration has not been implemented. This is a key area for future development.

### 5. The `OverlayChannel` API

This service class is the contract between the Flutter UI and the native platform code.

#### Methods (Flutter -> Native)

*   `Future<bool> startOverlay()`
    Invokes the native method to create and display the floating overlay. Returns `true` on success.

*   `Future<bool> stopOverlay()`
    Invokes the native method to destroy the floating overlay.

*   `Future<void> updateConfig()`
    A signal to the native service that one or more settings have changed. The native side is expected to re-fetch all its configuration from `SharedPreferences` and apply the updates.

*   `Future<Map> getPermissionState()`
    Checks if the required permissions (primarily the overlay permission) have been granted.

*   `Future<bool> openOverlaySettings()`
    Requests that the native platform open the system settings screen for the "display over other apps" permission.

#### Events (Native -> Flutter)

*   `Stream<dynamic> get overlayEvents`
    A broadcast stream that emits events from the native layer. The primary event is `overlayStateChanged`, which includes a boolean `running` field, allowing the Flutter UI to stay synchronized with the service's actual state.