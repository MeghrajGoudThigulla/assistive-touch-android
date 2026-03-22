package com.meghraj.assistivetouch

import io.flutter.plugin.common.EventChannel

object GlobalEventStream {
    var eventSink: EventChannel.EventSink? = null

    fun sendEvent(event: Map<String, Any>) {
        eventSink?.success(event)
    }

    fun sendError(code: String, message: String, details: Any?) {
        eventSink?.error(code, message, details)
    }
}
