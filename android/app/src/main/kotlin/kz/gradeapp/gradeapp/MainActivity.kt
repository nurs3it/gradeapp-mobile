package kz.gradeapp.gradeapp

import android.os.Build
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
    }
}
