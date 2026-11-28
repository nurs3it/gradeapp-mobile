package kz.gradeapp.gradeapp.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import kz.gradeapp.gradeapp.R

/**
 * W3 «Статус ребёнка», 2x2: one child per widget. Says where the child is and
 * how many grades are new — never which grades. The child is chosen in
 * [ChildStatusConfigureActivity] (the first one by default).
 */
class ChildStatusWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = WidgetData.load(context)
        val now = System.currentTimeMillis()
        for (id in ids) manager.updateAppWidget(id, render(context, data, id, now))
        // The picture changes by itself when the data turns a day old and when
        // a shown child's last lesson ends («В школе» → «Уроки закончились»).
        val stale = data?.generatedAt?.takeIf { it != 0L }?.plus(24 * 3600 * 1000L)
        val ends = ids.toList().mapNotNull { data?.child(ChildPrefs.get(context, it))?.until?.takeIf { u -> u != 0L } }
        val next = (ends + listOfNotNull(stale)).filter { it > now }.minOrNull()
        WidgetCommon.scheduleNext(context, ChildStatusWidget::class.java, next)
    }

    override fun onDeleted(context: Context, ids: IntArray) {
        for (id in ids) ChildPrefs.forget(context, id)
    }

    override fun onDisabled(context: Context) =
        WidgetCommon.scheduleNext(context, ChildStatusWidget::class.java, null)

    companion object {
        fun render(c: Context, data: WidgetData?, widgetId: Int, now: Long): RemoteViews {
            val v = RemoteViews(c.packageName, R.layout.widget_child)
            fun text(id: Int, s: String, color: Int) {
                v.setTextViewText(id, s)
                v.setTextColor(id, color)
                v.setViewVisibility(id, if (s.isEmpty()) View.GONE else View.VISIBLE)
            }
            val ink = WidgetCommon.color(c, R.color.g_ink)
            val ink2 = WidgetCommon.color(c, R.color.g_ink2)
            val ink3 = WidgetCommon.color(c, R.color.g_ink3)
            WidgetCommon.tint(v, R.id.bg, WidgetCommon.color(c, R.color.g_surface))
            val child = if (data == null || data.signedOut || data.role != "parent") null
            else data.child(ChildPrefs.get(c, widgetId))
            val open = WidgetCommon.open(c, data?.childUri(child) ?: "gradeapp://app/", 30 + widgetId)
            v.setOnClickPendingIntent(R.id.widget_root, open)

            if (child == null) {
                val msg = when {
                    data == null || data.signedOut -> data?.label("signedOut")?.ifEmpty { null } ?: "GradeApp"
                    data.role != "parent" -> c.getString(R.string.widget_child_parent_only)
                    else -> c.getString(R.string.widget_child_open)
                }
                text(R.id.eyebrow, "", ink3)
                text(R.id.status, msg, ink)
                text(R.id.grades, "", ink2)
                text(R.id.updated, "", ink3)
                return v
            }
            // Older than a day is never shown as if it were current (W1).
            val stale = data!!.isStale(now)
            val eyebrow = listOf(child.name, child.cls).filter { it.isNotEmpty() }.joinToString(" · ")
            text(R.id.eyebrow, eyebrow, ink2)
            if (stale || child.kind == "unknown") {
                text(R.id.status, data.label("stale"), ink)
                text(R.id.grades, "", ink2)
            } else {
                val color = when (child.kind) {
                    "in" -> WidgetCommon.color(c, R.color.g_ok)
                    "absent" -> WidgetCommon.color(c, R.color.g_bad)
                    "notyet" -> WidgetCommon.color(c, R.color.g_warn)
                    else -> ink
                }
                text(R.id.status, child.textAt(now), color)
                text(R.id.grades, child.gradesText, ink2)
            }
            text(R.id.updated, data.label("updated"), ink3)
            v.setContentDescription(
                R.id.widget_root,
                listOf(eyebrow, if (stale) data.label("stale") else child.textAt(now), if (stale) "" else child.gradesText)
                    .filter { it.isNotEmpty() }.joinToString(", "),
            )
            return v
        }
    }
}

/** Which child each widget instance shows (set in [ChildStatusConfigureActivity]). */
object ChildPrefs {
    private fun prefs(c: Context) = c.getSharedPreferences("ChildStatusWidget", Context.MODE_PRIVATE)
    fun get(c: Context, widgetId: Int): String? = prefs(c).getString("child_$widgetId", null)
    fun set(c: Context, widgetId: Int, childId: String) = prefs(c).edit().putString("child_$widgetId", childId).apply()
    fun forget(c: Context, widgetId: Int) = prefs(c).edit().remove("child_$widgetId").apply()
}
