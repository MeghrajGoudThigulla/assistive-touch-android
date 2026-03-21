import 'package:flutter/services.dart';

class OverlayChannel {
  static const MethodChannel _methodChannel = MethodChannel('com.meghraj.assistivetouch/methods');
  static const EventChannel _eventChannel = EventChannel('com.meghraj.assistivetouch/events');

  static Future<void> invokeAction(String actionName, [dynamic arguments]) async {
    try {
      await _methodChannel.invokeMethod(actionName, arguments);
    } on PlatformException catch (e) {
      print("Failed to invoke: '${e.message}'.");
    }
  }

  static Stream<dynamic> get overlayEvents {
    return _eventChannel.receiveBroadcastStream();
  }
}
