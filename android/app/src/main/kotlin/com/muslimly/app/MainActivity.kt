package com.muslimly.app

import android.content.Intent
import com.ryanheise.audioservice.AudioServiceActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Same as AudioServiceActivity, plus: when a widget tap re-opens an already
 * running app, hand the widget's deep link (muslimly://tracker|prayer) to Dart
 * ourselves. home_widget's own stream did not fire in that warm-start case.
 * Cold start is still read from the launch intent by home_widget.
 */
class MainActivity : AudioServiceActivity() {
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        val uri = intent.data
        if (uri != null && uri.scheme == "muslimly") {
            channel?.invokeMethod("widgetUri", uri.toString())
        }
    }

    companion object {
        const val CHANNEL = "com.muslimly.app/widget_launch"
    }
}
