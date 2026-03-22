# Other — gradle

# Gradle Wrapper Configuration

This document describes the Gradle Wrapper configuration for the Android project. The Gradle Wrapper is a crucial component that ensures a consistent and reliable build environment for all developers, regardless of their local machine setup.

## Overview

The Gradle Wrapper (`gradlew`) is a script included in the project's source code. Its primary purpose is to automatically download and use the specific version of Gradle defined by the project. This eliminates the need for developers to manually install and manage Gradle versions, preventing "works on my machine" issues related to build tool discrepancies.

When a developer runs a command like `./gradlew build`, the wrapper script consults the configuration, downloads the correct Gradle distribution if it's not already present, and then delegates the build task to it.

## Key Configuration: `gradle-wrapper.properties`

The behavior of the Gradle Wrapper is controlled by the `android/gradle/wrapper/gradle-wrapper.properties` file. This file dictates which version of Gradle to use and where to store it.

```properties
# android/gradle/wrapper/gradle-wrapper.properties

distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.13-all.zip
```

### Property Breakdown

*   **`distributionUrl`**: This is the most critical property. It is a direct link to the Gradle distribution ZIP file that the wrapper will download and execute.
    *   **Current Version**: The project is configured to use **Gradle 8.13**.
    *   **Distribution Type**: The `-all` suffix indicates that this distribution includes the Gradle source code and documentation, which provides better support and code completion in IDEs like Android Studio.

*   **`distributionBase` / `distributionPath`**: These properties define the location where the unpacked Gradle distribution is stored. By default, this is `~/.gradle/wrapper/dists`.

*   **`zipStoreBase` / `zipStorePath`**: These properties define the location where the downloaded ZIP file is stored. By default, this is also `~/.gradle/wrapper/dists`.

Using `GRADLE_USER_HOME` for the base paths is standard practice, allowing Gradle to cache distributions globally for the user across different projects.

## How It Works

The Gradle Wrapper provides a seamless, automated setup process.

```mermaid
sequenceDiagram
    participant Dev as Developer
    participant Wrapper as ./gradlew Script
    participant Properties as gradle-wrapper.properties
    participant Gradle as Gradle 8.13

    Dev->>Wrapper: Executes a task (e.g., `./gradlew build`)
    Wrapper->>Properties: Reads distributionUrl
    Wrapper->>Gradle: Is Gradle 8.13 downloaded?
    alt Not downloaded
        Wrapper->>Gradle: Download from URL and unpack
    end
    Wrapper->>Gradle: Delegate 'build' task
    Gradle-->>Dev: Executes task and returns output
```

1.  A developer invokes the wrapper script (`./gradlew` or `gradlew.bat`) from the command line.
2.  The script reads `gradle-wrapper.properties` to find the `distributionUrl`.
3.  It checks the local cache (typically in `~/.gradle/wrapper/dists`) for the specified Gradle version.
4.  If the version is not found, it downloads the ZIP file from the URL, verifies its integrity, and unpacks it into the cache.
5.  The wrapper then uses this newly downloaded (or already cached) Gradle distribution to execute the requested build task.

## Developer Guide

### Using the Wrapper

To ensure you are using the project's specified Gradle version, **always** use the wrapper script to execute Gradle tasks. Do not use a globally installed `gradle` command.

**Correct:**
```bash
# On Linux or macOS
./gradlew build

# On Windows
.\gradlew.bat build
```

**Incorrect:**
```bash
# Avoid this, as it may use a different, incompatible Gradle version
gradle build
```

### Updating the Gradle Version

To upgrade the project to a new version of Gradle, do not manually edit the `distributionUrl` in the properties file. Instead, use the wrapper's built-in task. This ensures all associated wrapper files are updated correctly.

Run the following command from the project root, replacing `<new-version>` with the target version number:

```bash
./gradlew wrapper --gradle-version <new-version>
```

For example, to upgrade to Gradle 8.14:

```bash
./gradlew wrapper --gradle-version 8.14
```

After running the command, the `distributionUrl` in `gradle-wrapper.properties` will be updated. Commit this change to version control to share the update with the rest of the team.