package kz.gradeapp.gradeapp

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.HapticFeedbackConstants
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Notification-style haptics for lib/ui/haptics.dart.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kz.gradeapp/haptics").setMethodCallHandler { call, result ->
            if (call.method != "notify") {
                result.notImplemented()
                return@setMethodCallHandler
            }
            val constant = when {
                Build.VERSION.SDK_INT < Build.VERSION_CODES.R -> HapticFeedbackConstants.LONG_PRESS
                call.arguments == "error" -> HapticFeedbackConstants.REJECT
                call.arguments == "warning" -> HapticFeedbackConstants.LONG_PRESS
                else -> HapticFeedbackConstants.CONFIRM
            }
            window.decorView.performHapticFeedback(constant)
            result.success(null)
        }
        // Notification channels and settings for lib/features/notifications/push.dart.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kz.gradeapp/system").setMethodCallHandler { call, result ->
            when (call.method) {
                "createChannels" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        val manager = getSystemService(NotificationManager::class.java)
                        val names = call.arguments as? Map<*, *> ?: emptyMap<String, String>()
                        for ((id, name) in names) {
                            val importance = if (id == "chat") NotificationManager.IMPORTANCE_HIGH else NotificationManager.IMPORTANCE_DEFAULT
                            val channel = NotificationChannel(id.toString(), name.toString(), importance)
                            channel.lockscreenVisibility = android.app.Notification.VISIBILITY_PRIVATE
                            manager.createNotificationChannel(channel)
                        }
                    }
                    result.success(null)
                }
                "openSettings" -> {
                    val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS)
                        .putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    startActivity(intent)
                    result.success(null)
                }
                "setBadge" -> result.success(null) // launchers count notifications themselves
                else -> result.notImplemented()
            }
        }
    }
}
