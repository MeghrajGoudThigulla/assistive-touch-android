# Other — linux

This document provides a technical overview of the `linux/CMakeLists.txt` file, which serves as the master build script for the Linux version of the Flutter application.

## Overview

The `linux/CMakeLists.txt` file orchestrates the entire native build process for the Linux target. It uses CMake to configure the project, compile the C++ host application (the "runner"), integrate the Flutter engine and compiled Dart code, and assemble a distributable application bundle.

Its primary responsibilities are:
1.  **Project Configuration**: Defining application-specific metadata like the executable name and application ID.
2.  **Dependency Management**: Locating and linking against system libraries, primarily GTK+.
3.  **Flutter Integration**: Coordinating with the Flutter toolchain to build Dart code and bundle assets.
4.  **Native Code Compilation**: Invoking the build process for the C++ runner code located in the `runner/` subdirectory.
5.  **Bundling**: Assembling the final, relocatable application package that includes the executable, libraries, and assets.

## Key Configuration Variables

At the top of the file, you will find several key variables that define the application's identity:

-   `set(BINARY_NAME "assistive_touch_android")`
    This variable determines the filename of the final executable. Changing this value will change the name of the binary inside the application bundle.

-   `set(APPLICATION_ID "com.meghraj.assistive_touch_android")`
    This sets the GTK application identifier. It's a unique, reverse-domain-style string used by the Linux desktop environment for things like window grouping, D-Bus registration, and desktop file associations.

## Build Process and Execution Flow

The build process is a sequence of configuration, compilation, and assembly steps orchestrated by CMake. The script ensures that all components—native C++ code, Dart code, and assets—are built and placed correctly.

```mermaid
graph TD
    A[Start CMake Build] --> B{Project Configuration};
    B -- Reads --> C[Top-level CMakeLists.txt];
    C --> D[Include flutter/];
    C --> E[Include runner/];
    C --> F[Find System Libs (GTK+)];
    D -- Defines --> G(flutter_assemble Target);
    E -- Compiles --> H(C++ Runner Code);
    F & H -- Link --> I[Create Executable (${BINARY_NAME})];
    G -- Is a dependency for --> I;
    I -- "cmake --install" --> J[Assemble Final Bundle];
```

1.  **Configuration**: CMake reads this file to set up the project, defining variables and locating dependencies like GTK+.
2.  **Flutter Integration**: The script includes `flutter/CMakeLists.txt`, which is managed by the Flutter SDK. This subdirectory defines the crucial `flutter_assemble` target. This target runs the Flutter tool to compile Dart code (to JIT or AOT) and prepare all Flutter assets.
3.  **Native Runner Compilation**: It then includes `runner/CMakeLists.txt`, which contains the rules for compiling the C++ code that hosts the Flutter engine.
4.  **Dependency Linking**: The script creates a dependency between the main executable (`BINARY_NAME`) and `flutter_assemble`. This ensures that the Flutter assets and Dart code are ready before the final C++ executable is linked.
5.  **Bundling (Installation)**: The final stage, triggered by `cmake --install` (or a build in an IDE), is the assembly of the application bundle. This is not a system-wide installation but rather the creation of a self-contained, relocatable directory.

## The Application Bundle

The ultimate output of this build script is a self-contained application bundle located in `build/linux/<build_type>/bundle/`. The `Installation` section of the `CMakeLists.txt` file is dedicated to constructing this bundle.

The structure is designed to be relocatable, thanks to the `CMAKE_INSTALL_RPATH` setting:

```
set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")
```

This tells the executable to look for its shared libraries in a `lib` directory located right next to it.

A typical release bundle has the following structure:

```
bundle/
├── assistive_touch_android      # The main executable
├── data/
│   ├── flutter_assets/          # Your app's assets (images, fonts, etc.)
│   └── icudtl.dat               # ICU data for internationalization
└── lib/
    ├── libflutter_linux_gtk.so  # The Flutter engine library
    ├── app.so                   # AOT-compiled Dart code (Release/Profile builds)
    └── ...                      # Any libraries from native plugins
```

The script meticulously copies each required component into this structure:
-   The compiled C++ executable (`assistive_touch_android`).
-   The core Flutter engine library (`libflutter_linux_gtk.so`).
-   The Ahead-Of-Time (AOT) compiled Dart library (`app.so`) for Profile and Release builds.
-   All Flutter assets from `build/flutter_assets`.
-   Any bundled libraries provided by native plugins (`PLUGIN_BUNDLED_LIBRARIES`).

## Key Functions and Targets

### `function(APPLY_STANDARD_SETTINGS TARGET)`

This is a helper function that applies a consistent set of compilation flags to a given target. It enforces C++14 standard, enables all warnings, treats warnings as errors (`-Wall -Werror`), and applies optimizations (`-O3`) for non-Debug builds. This promotes code quality and consistency for both the main runner and any plugins.

### `flutter_assemble` Target

This is not a target defined in this file, but it is the most critical dependency. It is defined by the Flutter toolchain's CMake files (`flutter/`). When this target is run, it invokes `flutter build` commands to prepare all framework-dependent assets, including:
-   Compiling Dart code.
-   Copying assets from your project's `assets` directory.
-   Preparing font files.

By making the main executable depend on `flutter_assemble`, the build system guarantees that all Flutter-side artifacts are up-to-date before the native build completes.