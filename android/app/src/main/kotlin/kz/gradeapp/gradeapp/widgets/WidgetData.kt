package kz.gradeapp.gradeapp.widgets

import android.content.Context
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

/**
 * What the app wrote for the widgets (lib/features/platform/widget_snapshot.dart,
 * schema v1; iOS reads the same JSON in ios/GradeAppWidgets/Snapshot.swift).
 * The widgets only answer «what is on at time T» from it and never invent a
 * lesson.
 */
class Slot(
    val id: String,
    val subject: String,
    val start: String,
    val end: String,
    val room: String,
    val cls: String,
    val ci: Int,
    val date: String,
    val starts: Long,
    val ends: Long,
)

class WidgetData(private val json: JSONObject) {
    val role: String = json.optString("role")
    val who: String = json.optString("who")
    val isTeacher get() = role == "teacher"
    val signedOut get() = role == "none"
    private val labels = json.optJSONObject("labels") ?: JSONObject()
    private val hw = json.optJSONObject("homework")

    fun label(k: String): String = labels.optString(k)

    val generatedAt: Long = parseIso(json.optString("generatedAt"))

    val slots: List<Slot> by lazy {
        val out = ArrayList<Slot>()
        val days = json.optJSONArray("days")
        for (d in 0 until (days?.length() ?: 0)) {
            val day = days!!.getJSONObject(d)
            val date = day.optString("date")
            val ls = day.optJSONArray("lessons") ?: continue
            for (i in 0 until ls.length()) {
                val l = ls.getJSONObject(i)
                val s = parseLocal("$date ${l.optString("start")}")
                val e = parseLocal("$date ${l.optString("end")}")
                if (s == 0L || e == 0L) continue
                out.add(
                    Slot(
                        l.optString("id"), l.optString("subject"), l.optString("start"), l.optString("end"),
                        l.optString("room"), l.optString("cls"), l.optInt("ci"), date, s, e,
                    ),
                )
            }
        }
        out.sortedBy { it.starts }
    }

    val homeworkCount: Int get() = hw?.optJSONArray("items")?.length() ?: 0
    val homeworkMinutes: Int get() = hw?.optInt("minutes") ?: 0

    /** Data older than a day is never shown as if it were current (W1). */
    fun isStale(now: Long) = generatedAt == 0L || now - generatedAt > 24 * 3600 * 1000L

    fun current(now: Long) = slots.firstOrNull { it.starts <= now && now < it.ends }
    fun next(now: Long) = slots.firstOrNull { it.starts > now }

    /** The next moment the picture changes: a bell or the stale boundary. */
    fun nextChange(now: Long): Long? {
        val points = ArrayList<Long>()
        for (s in slots) {
            points.add(s.starts)
            points.add(s.ends)
        }
        if (generatedAt != 0L) points.add(generatedAt + 24 * 3600 * 1000L)
        return points.filter { it > now }.minOrNull()
    }

    fun room(s: Slot): String = if (s.room.isEmpty()) "" else label("roomFmt").replace("%s", s.room)
    fun minutes(n: Int): String = label("minFmt").replace("%s", "$n")

    /** Where a tap goes: gradeapp://app/... → go_router. */
    fun uri(s: Slot?): String = when (role) {
        "teacher" -> if (s != null) "gradeapp://app/lesson/${s.id}" else "gradeapp://app/t/today"
        "parent" -> "gradeapp://app/p/week"
        else -> "gradeapp://app/s/week"
    }

    val homeworkUri: String get() = if (role == "parent") "gradeapp://app/p/week" else "gradeapp://app/s/tasks"

    companion object {
        fun load(context: Context): WidgetData? {
            val raw = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
                .getString("snapshot", null) ?: return null
            return try {
                WidgetData(JSONObject(raw))
            } catch (e: Exception) {
                null
            }
        }

        private fun parseIso(s: String): Long {
            if (s.isEmpty()) return 0L
            for (pattern in listOf("yyyy-MM-dd'T'HH:mm:ss.SSSSSS'Z'", "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", "yyyy-MM-dd'T'HH:mm:ss'Z'")) {
                try {
                    val f = SimpleDateFormat(pattern, Locale.US)
                    f.timeZone = java.util.TimeZone.getTimeZone("UTC")
                    return f.parse(s)?.time ?: continue
                } catch (e: Exception) {
                    // next pattern
                }
            }
            return 0L
        }

        private fun parseLocal(s: String): Long = try {
            SimpleDateFormat("yyyy-MM-dd HH:mm", Locale.US).parse(s)?.time ?: 0L
        } catch (e: Exception) {
            0L
        }

        fun clock(t: Long): String = SimpleDateFormat("HH:mm", Locale.US).format(Date(t))
    }
}
