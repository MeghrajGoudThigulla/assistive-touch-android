import 'package:flutter/services.dart';

class OverlayChannel {
  static const MethodChannel _methodChannel = MethodChannel('com.meghraj.assistivetouch/methods');
  static const EventChannel _eventChannel = EventChannel('com.meghraj.assistivetouch/events');

  // --- Overlay Actions ---
  
  static Future<bool> startOverlay() async {
    try {
      final bool result = await _methodChannel.invokeMethod('overlay.start');
      return result;
    } on PlatformException catch (e) {
      print("Failed to start overlay: '${e.message}'.");
      return false;
    }
  }

  static Future<bool> stopOverlay() async {
    try {
      final bool result = await _methodChannel.invokeMethod('overlay.stop');
      return result;
    } on PlatformException catch (e) {
      print("Failed to stop overlay: '${e.message}'.");
      return false;
    }
  }

  // --- Permissions Actions ---

  static Future<Map<dynamic, dynamic>> getPermissionState() async {
    try {
      final Map<dynamic, dynamic> state = await _methodChannel.invokeMethod('permissions.getState');
      return state;
    } on PlatformException catch (e) {
      print("Failed to fetch permissions: '${e.message}'.");
      return {'overlay': false, 'accessibility': false, 'deviceAdmin': false};
    }
  }

  static Future<bool> openOverlaySettings() async {
    try {
      final bool result = await _methodChannel.invokeMethod('permissions.openOverlaySettings');
      return result;
    } on PlatformException catch (e) {
      print("Failed to open overlay settings: '${e.message}'.");
      return false;
    }
  }

  // --- Event Streams ---

  static Stream<dynamic> get overlayEvents {
    return _eventChannel.receiveBroadcastStream();
  }
}
