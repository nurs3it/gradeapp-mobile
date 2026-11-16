package kz.gradeapp.gradeapp.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import kz.gradeapp.gradeapp.R

/** W1 «Следующий урок», 2x2. */
class NextLessonWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = WidgetData.load(context)
        val now = System.currentTimeMillis()
        for (id in ids) manager.updateAppWidget(id, render(context, data, now))
        WidgetCommon.scheduleNext(context, NextLessonWidget::class.java, data?.nextChange(now))
    }

    override fun onDisabled(context: Context) =
        WidgetCommon.scheduleNext(context, NextLessonWidget::class.java, null)

    private fun render(c: Context, data: WidgetData?, now: Long): RemoteViews {
        val v = RemoteViews(c.packageName, R.layout.widget_next)
        fun text(id: Int, s: String, color: Int) {
            v.setTextViewText(id, s)
            v.setTextColor(id, color)
            v.setViewVisibility(id, if (s.isEmpty()) View.GONE else View.VISIBLE)
        }
        val onFill = WidgetCommon.color(c, R.color.g_on_fill)
        val onFillSoft = WidgetCommon.color(c, R.color.g_on_fill_soft)
        val ink = WidgetCommon.color(c, R.color.g_ink)
        val ink3 = WidgetCommon.color(c, R.color.g_ink3)

        // One of: signed out / stale / nothing left / the lesson.
        val slot = if (data == null || data.signedOut || data.isStale(now)) null else data.current(now) ?: data.next(now)
        if (slot == null || data == null) {
            WidgetCommon.tint(v, R.id.bg, WidgetCommon.color(c, R.color.g_surface))
            val msg = when {
                data == null || data.signedOut -> data?.label("signedOut")?.ifEmpty { null } ?: "GradeApp"
                data.isStale(now) -> data.label("stale")
                else -> data.label("noMore")
            }
            text(R.id.eyebrow, "", ink)
            text(R.id.title, msg, ink)
            text(R.id.sub, "", ink)
            v.setViewVisibility(R.id.countdown, View.GONE)
            text(R.id.countdown_label, "", ink)
            text(R.id.updated, if (data == null || data.signedOut) "" else data.label("updated"), ink3)
            v.setOnClickPendingIntent(R.id.widget_root, WidgetCommon.open(c, "gradeapp://app/", 10))
            return v
        }
        val running = slot.starts <= now
        WidgetCommon.tint(v, R.id.bg, WidgetCommon.fill(c, slot.ci))
        text(R.id.eyebrow, "${if (running) data.label("now") else data.label("nextShort")} · ${slot.start}".uppercase(), onFillSoft)
        if (data.isTeacher && slot.cls.isNotEmpty()) {
            text(R.id.title, slot.cls, onFill)
            text(R.id.sub, listOf(slot.subject, data.room(slot)).filter { it.isNotEmpty() }.joinToString(" · "), onFillSoft)
        } else {
            text(R.id.title, slot.subject, onFill)
            text(R.id.sub, data.room(slot), onFillSoft)
        }
        v.setViewVisibility(R.id.countdown, View.VISIBLE)
        v.setTextColor(R.id.countdown, onFill)
        WidgetCommon.countdown(v, R.id.countdown, if (running) slot.ends else slot.starts, now)
        text(R.id.countdown_label, if (running) data.label("endsIn") else data.label("startsIn"), onFillSoft)
        text(R.id.updated, data.label("updated"), onFillSoft)
        v.setOnClickPendingIntent(R.id.widget_root, WidgetCommon.open(c, data.uri(slot), 11))
        return v
    }
}
