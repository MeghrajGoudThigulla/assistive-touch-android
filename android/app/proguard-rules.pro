# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Assistive Touch Native Code (Important so reflection/MethodChannel doesn't unintentionally drop isolated receivers in production App Bundles)
-keep class com.meghraj.assistivetouch.** { *; }
