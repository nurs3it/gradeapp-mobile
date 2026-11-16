package kz.gradeapp.gradeapp.widgets

import android.app.AlarmManager
import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.SystemClock
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import kz.gradeapp.gradeapp.MainActivity
import kz.gradeapp.gradeapp.R

/** Helpers shared by the two widgets. */
object WidgetCommon {
    private val subjectFill = intArrayOf(
        R.color.g_subject_0_fill, R.color.g_subject_1_fill, R.color.g_subject_2_fill, R.color.g_subject_3_fill,
        R.color.g_subject_4_fill, R.color.g_subject_5_fill, R.color.g_subject_6_fill, R.color.g_subject_7_fill,
    )
    private val subjectMarker = intArrayOf(
        R.color.g_subject_0_marker, R.color.g_subject_1_marker, R.color.g_subject_2_marker, R.color.g_subject_3_marker,
        R.color.g_subject_4_marker, R.color.g_subject_5_marker, R.color.g_subject_6_marker, R.color.g_subject_7_marker,
    )

    fun color(c: Context, res: Int) = ContextCompat.getColor(c, res)
    fun fill(c: Context, i: Int) = color(c, subjectFill[Math.floorMod(i, subjectFill.size)])
    fun marker(c: Context, i: Int) = color(c, subjectMarker[Math.floorMod(i, subjectMarker.size)])

    /** Tints an ImageView-based rounded sheet. */
    fun tint(v: RemoteViews, id: Int, color: Int) = v.setInt(id, "setColorFilter", color)

    /** Opens the app on [uri] (custom scheme, handled by go_router). */
    fun open(c: Context, uri: String, request: Int): PendingIntent {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(uri), c, MainActivity::class.java)
            .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP)
        return PendingIntent.getActivity(c, request, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
    }

    /** The OS ticks the countdown (Chronometer); no updates are needed for it. */
    fun countdown(v: RemoteViews, id: Int, target: Long, now: Long) {
        v.setChronometerCountDown(id, true)
        v.setChronometer(id, SystemClock.elapsedRealtime() + (target - now), null, true)
    }

    /**
     * Wakes the widget at the next bell so it never shows a lesson that is
     * over. Inexact on purpose (no exact-alarm permission); the system's own
     * 30-minute update is the fallback — and the picture is always computed
     * from the clock, never from the time of the last update.
     */
    fun scheduleNext(c: Context, cls: Class<*>, at: Long?) {
        val am = c.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(c, cls).setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE)
        val ids = AppWidgetManager.getInstance(c).getAppWidgetIds(ComponentName(c, cls))
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids)
        val pi = PendingIntent.getBroadcast(c, 0, intent, PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT)
        if (at == null || ids.isEmpty()) am.cancel(pi) else am.setAndAllowWhileIdle(AlarmManager.RTC, at + 1000, pi)
    }
}
