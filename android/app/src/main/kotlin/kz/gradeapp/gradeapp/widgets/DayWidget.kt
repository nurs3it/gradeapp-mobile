package kz.gradeapp.gradeapp.widgets

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.view.View
import android.widget.RemoteViews
import kz.gradeapp.gradeapp.R

/** W2 «День», 4x2. */
class DayWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = WidgetData.load(context)
        val now = System.currentTimeMillis()
        for (id in ids) manager.updateAppWidget(id, render(context, data, now))
        WidgetCommon.scheduleNext(context, DayWidget::class.java, data?.nextChange(now))
    }

    override fun onDisabled(context: Context) = WidgetCommon.scheduleNext(context, DayWidget::class.java, null)

    private data class Row(val time: Int, val bar: Int, val title: Int, val room: Int, val box: Int)

    private val rows = listOf(
        Row(R.id.row1_time, R.id.row1_bar, R.id.row1_title, R.id.row1_room, R.id.row1),
        Row(R.id.row2_time, R.id.row2_bar, R.id.row2_title, R.id.row2_room, R.id.row2),
        Row(R.id.row3_time, R.id.row3_bar, R.id.row3_title, R.id.row3_room, R.id.row3),
    )

    private fun render(c: Context, data: WidgetData?, now: Long): RemoteViews {
        val v = RemoteViews(c.packageName, R.layout.widget_day)
        fun text(id: Int, s: String, color: Int) {
            v.setTextViewText(id, s)
            v.setTextColor(id, color)
        }
        val onFill = WidgetCommon.color(c, R.color.g_on_fill)
        val onFillSoft = WidgetCommon.color(c, R.color.g_on_fill_soft)
        val ink = WidgetCommon.color(c, R.color.g_ink)
        val ink2 = WidgetCommon.color(c, R.color.g_ink2)
        val ink3 = WidgetCommon.color(c, R.color.g_ink3)
        WidgetCommon.tint(v, R.id.bg, WidgetCommon.color(c, R.color.g_surface))

        val hero = if (data == null || data.signedOut || data.isStale(now)) null else data.current(now) ?: data.next(now)
        if (hero == null || data == null) {
            // The whole sheet becomes one message; never a stale lesson.
            val msg = when {
                data == null || data.signedOut -> data?.label("signedOut")?.ifEmpty { null } ?: "GradeApp"
                data.isStale(now) -> data.label("stale")
                else -> data.label("noMore")
            }
            WidgetCommon.tint(v, R.id.hero_bg, WidgetCommon.color(c, R.color.g_surface2))
            text(R.id.hero_eyebrow, "", ink)
            text(R.id.hero_title, msg, ink)
            text(R.id.hero_sub, "", ink)
            v.setViewVisibility(R.id.hero_countdown, View.GONE)
            for (r in rows) v.setViewVisibility(r.box, View.INVISIBLE)
            text(R.id.homework, "", ink)
            text(R.id.updated, if (data == null || data.signedOut) "" else data.label("updated"), ink3)
            v.setOnClickPendingIntent(R.id.widget_root, WidgetCommon.open(c, "gradeapp://app/", 20))
            return v
        }
        val running = hero.starts <= now
        WidgetCommon.tint(v, R.id.hero_bg, WidgetCommon.fill(c, hero.ci))
        text(R.id.hero_eyebrow, (if (running) data.label("now") else data.label("nextShort")).uppercase(), onFillSoft)
        text(R.id.hero_title, if (data.isTeacher && hero.cls.isNotEmpty()) hero.cls else hero.subject, onFill)
        text(R.id.hero_sub, data.room(hero), onFillSoft)
        v.setViewVisibility(R.id.hero_countdown, View.VISIBLE)
        v.setTextColor(R.id.hero_countdown, onFill)
        WidgetCommon.countdown(v, R.id.hero_countdown, if (running) hero.ends else hero.starts, now)
        v.setOnClickPendingIntent(R.id.hero, WidgetCommon.open(c, data.uri(hero), 21))

        val after = data.slots.filter { it.starts >= hero.ends && it.date == hero.date }
        for ((i, r) in rows.withIndex()) {
            val s = after.getOrNull(i)
            if (s == null) {
                v.setViewVisibility(r.box, View.INVISIBLE)
                continue
            }
            v.setViewVisibility(r.box, View.VISIBLE)
            text(r.time, s.start, ink2)
            WidgetCommon.tint(v, r.bar, WidgetCommon.marker(c, s.ci))
            text(r.title, if (data.isTeacher && s.cls.isNotEmpty()) "${s.cls} · ${s.subject}" else s.subject, ink)
            text(r.room, data.room(s), ink3)
            v.setOnClickPendingIntent(r.box, WidgetCommon.open(c, data.uri(s), 30 + i))
        }
        if (data.isTeacher) {
            text(R.id.homework, "", ink)
        } else {
            val n = data.homeworkCount
            val plate = if (n == 0) data.label("noHomework") else
                "${data.label("homework")} · $n" + if (data.homeworkMinutes > 0) " · ≈ ${data.minutes(data.homeworkMinutes)}" else ""
            text(R.id.homework, plate, ink)
            v.setOnClickPendingIntent(R.id.homework, WidgetCommon.open(c, data.homeworkUri, 40))
        }
        text(R.id.updated, data.label("updated"), ink3)
        return v
    }
}
