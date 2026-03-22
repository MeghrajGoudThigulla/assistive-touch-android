# assistive-touch-android — Wiki

# Welcome to the Assistive Touch Android Wiki!

Hello and welcome! This wiki is the central source of truth for the `assistive-touch-android` project. If you're a new developer joining the team, you're in the right place. This page provides a high-level overview of the project's architecture, its key components, and how to get it running.

## What is Assistive Touch Android?

Assistive Touch Android is a Flutter application designed to provide a native, system-wide floating overlay on Android devices. This overlay gives users quick access to common system actions, similar to the AssistiveTouch feature on iOS.

The project is a hybrid application:
*   A **Flutter UI** is used for the main application screen, which handles user onboarding, settings, and starting/stopping the service.
*   A **Native Android Service** is responsible for drawing and managing the floating button and its associated panel, ensuring it can run persistently over other applications.

## High-Level Architecture

The application's architecture is designed to separate the user-facing configuration from the core background functionality. The Flutter application acts as a controller for the powerful native Android service that provides the actual assistive touch feature.

This separation allows us to leverage Flutter for building a beautiful, cross-platform UI while using native Android code for the performance-critical, system-level overlay feature.

```mermaid
graph TD
    subgraph "User's Device"
        User -- "Configures via" --> FlutterApp[Flutter Application (UI)]
        User -- "Interacts with" --> FloatingButton[Assistive Touch Overlay]

        subgraph "Native Android Layer"
            AndroidHost[Android Application Host]
            AssistiveService[Android Assistive Touch Service]
            FloatingButton -- "Managed by" --> AssistiveService
        end

        FlutterApp -- "Sends commands to" --> AndroidHost
        AndroidHost -- "Starts & Stops" --> AssistiveService
    end
```

### Key Components

The user-facing part of the app is a standard **[Flutter Application](flutter-application.md)**. Its main job is to guide users through onboarding and provide a simple screen to enable or disable the assistive touch feature.

When the user interacts with the Flutter UI, those commands are sent to the native layer through the **[Android Application Host](android-application-host.md)**. This module acts as the crucial bridge between the Dart world and the Android world, managing permissions and the lifecycle of the native service.

The core of the project is the **[Android Assistive Touch Service](android-assistive-touch-service.md)**. This is a native Android background service that draws the floating button on the screen, remaining active even when the main Flutter application is closed. It is responsible for handling user taps on the button, displaying the action panel, and executing the selected actions.

While the primary feature is Android-specific, this is a full Flutter project with native hosts for other platforms, including the **[iOS Application Host](ios-application-host.md)**, **[macOS Application Host](macos-application-host.md)**, **[Linux Application Host](linux-application-host.md)**, and **[Windows Application Host](windows-application-host.md)**. These modules serve as the entry points for running the configuration UI on their respective platforms. All these hosts rely on the auto-generated **[Platform Plugin Registration](platform-plugin-registration.md)** to connect platform-specific plugin code.

### Core User Flows

Understanding a couple of key user flows can help clarify how the components work together.

**1. Starting the Service**
1.  The user launches the application and sees the UI rendered by the **Flutter Application**.
2.  On the main screen, the user taps the "Start Service" button.
3.  The Flutter app sends a command over the platform channel to the **Android Application Host**.
4.  The Host receives this command and starts the **Android Assistive Touch Service**.
5.  The Service then creates and displays the floating button overlay on the screen, which is now visible over any application.

**2. Interacting with the Floating Button**
1.  With the service running, the user taps the floating button on their screen.
2.  The **Android Assistive Touch Service**, which is listening for touch events on the button, detects the tap.
3.  In response, the service inflates and displays a panel view containing various action icons (e.g., Home, Back, Lock Screen).
4.  When the user taps an action or taps outside the panel, the service executes the corresponding command and closes the panel, leaving only the floating button visible again.

## Getting Started

To get the project running on your local machine, you'll need the Flutter SDK and the Android SDK configured.

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    cd assistive-touch-android
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the application:**
    Connect an Android device or start an emulator, then run:
    ```bash
    flutter run
    ```