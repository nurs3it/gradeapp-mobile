package kz.gradeapp.native_notif

import android.app.Notification
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.service.notification.StatusBarNotification
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

/**
 * Two things flutter_local_notifications cannot do:
 *  - `addPublicVersion`: a redacted public version for notifications shown
 *    with VISIBILITY_PRIVATE (the lock screen of a secure device);
 *  - `promoteLessonLive`: Android 16 Live Update (ProgressStyle + promoted
 *    ongoing) for the lesson-in-progress notification.
 * Both rebuild the already-posted notification with recoverBuilder, so the
 * buttons and PendingIntents the Dart side attached keep working.
 * Registered in every Flutter engine, including the FCM background one.
 */
class GradeappNativePlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private val worker = Executors.newSingleThreadExecutor()
    private val main = Handler(Looper.getMainLooper())

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, "kz.gradeapp/notif_native")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<Int>("id")
        if (id == null) {
            result.notImplemented()
            return
        }
        val tag = call.argument<String>("tag")
        val extra: (Notification.Builder) -> Unit = when (call.method) {
            "addPublicVersion" -> { _ -> }
            "promoteLessonLive" -> { b -> promote(b, call) }
            else -> {
                result.notImplemented()
                return
            }
        }
        val publicTitle = call.argument<String>("publicTitle") ?: call.argument<String>("title")
        val publicBody = call.argument<String>("publicBody") ?: call.argument<String>("body")
        // The Dart side posts through a platform channel of its own, so the
        // notification can still be on its way: look for it for ~1 s.
        worker.execute {
            var done = false
            for (attempt in 0 until 10) {
                val posted = find(id, tag)
                if (posted != null) {
                    done = rebuild(posted.notification, id, tag, publicTitle, publicBody, extra)
                    break
                }
                Thread.sleep(100)
            }
            main.post { result.success(done) }
        }
    }

    private fun find(id: Int, tag: String?): StatusBarNotification? {
        val manager = context.getSystemService(NotificationManager::class.java)
        return manager.activeNotifications.firstOrNull { it.id == id && it.tag == tag }
    }

    private fun rebuild(
        n: Notification,
        id: Int,
        tag: String?,
        publicTitle: String?,
        publicBody: String?,
        extra: (Notification.Builder) -> Unit,
    ): Boolean {
        return try {
            val builder = Notification.Builder.recoverBuilder(context, n)
            if (publicTitle != null) {
                val pub = Notification.Builder(context, n.channelId)
                    .setContentTitle(publicTitle)
                    .setContentText(publicBody ?: "")
                n.smallIcon?.let { pub.setSmallIcon(it) }
                builder.setPublicVersion(pub.build())
                builder.setVisibility(Notification.VISIBILITY_PRIVATE)
            }
            extra(builder)
            // Same id, no new sound or heads-up.
            builder.setOnlyAlertOnce(true)
            context.getSystemService(NotificationManager::class.java).notify(tag, id, builder.build())
            true
        } catch (e: Exception) {
            android.util.Log.w("gradeapp_native", "rebuild failed", e)
            false
        }
    }

    // Android 16 Live Update. Criteria: ongoing, has a title, no custom views,
    // not colorized, a non-minimum channel; ProgressStyle from the bell times.
    private fun promote(b: Notification.Builder, call: MethodCall) {
        if (Build.VERSION.SDK_INT < 36) return
        val start = call.argument<Number>("startMs")!!.toLong()
        val end = call.argument<Number>("endMs")!!.toLong()
        val total = ((end - start) / 1000).toInt().coerceAtLeast(1)
        val done = ((System.currentTimeMillis() - start) / 1000).toInt().coerceIn(0, total)
        b.setStyle(
            Notification.ProgressStyle()
                .setStyledByProgress(false)
                .setProgressSegments(listOf(Notification.ProgressStyle.Segment(total)))
                .setProgress(done)
        )
        // setRequestPromotedOngoing(true) is the extra below (the setter is not
        // in every API 36 SDK revision).
        b.extras.putBoolean("android.requestPromotedOngoing", true)
        b.setShortCriticalText(call.argument<String>("shortText"))
        b.setOngoing(true)
    }
}
