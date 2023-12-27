package com.example.silent_mode_app // Ensure this package name matches your project's

import android.os.Bundle
import android.media.AudioManager
import android.content.Context
import androidx.core.content.ContextCompat
import androidx.core.app.ActivityCompat
import android.Manifest
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "silent_mode_channel"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when(call.method) {
                "setSilentMode" -> {
                    call.argument<Boolean>("silent")?.let { silent ->
                        setSilentMode(silent)
                        result.success(1)
                    } ?: run {
                        result.error("ARGUMENT_ERROR", "Argument 'silent' not found", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun setSilentMode(silent: Boolean) {
        val audioManager: AudioManager = getSystemService(Context.AUDIO_SERVICE) as AudioManager
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.MODIFY_AUDIO_SETTINGS) == PackageManager.PERMISSION_GRANTED) {
            if (silent) {
                audioManager.ringerMode = AudioManager.RINGER_MODE_SILENT
            } else {
                audioManager.ringerMode = AudioManager.RINGER_MODE_NORMAL
            }
        } else {
            ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.MODIFY_AUDIO_SETTINGS), 0)
        }
    }

    // Add other necessary overrides and custom logic
}
