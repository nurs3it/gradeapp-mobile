package kz.gradeapp.gradeapp.widgets

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.Intent
import android.os.Bundle
import android.widget.ArrayAdapter
import android.widget.ListView
import kz.gradeapp.gradeapp.R

/**
 * Picks the child for one «Статус ребёнка» widget. With one child (or none
 * known yet) there is nothing to pick: the widget is placed at once and shows
 * the first child; the picker can be reopened through «reconfigure».
 */
class ChildStatusConfigureActivity : Activity() {
    private var widgetId = AppWidgetManager.INVALID_APPWIDGET_ID

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setResult(RESULT_CANCELED)
        widgetId = intent?.extras?.getInt(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID)
            ?: AppWidgetManager.INVALID_APPWIDGET_ID
        if (widgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
            finish()
            return
        }
        val kids = WidgetData.load(this)?.children ?: emptyList()
        if (kids.size <= 1) {
            done()
            return
        }
        setTitle(R.string.widget_child_pick)
        val list = ListView(this)
        list.adapter = ArrayAdapter(
            this,
            android.R.layout.simple_list_item_1,
            kids.map { listOf(it.name, it.cls).filter { s -> s.isNotEmpty() }.joinToString(" · ") },
        )
        list.setOnItemClickListener { _, _, pos, _ ->
            ChildPrefs.set(this, widgetId, kids[pos].id)
            done()
        }
        setContentView(list)
    }

    private fun done() {
        val manager = AppWidgetManager.getInstance(this)
        manager.updateAppWidget(
            widgetId,
            ChildStatusWidget.render(this, WidgetData.load(this), widgetId, System.currentTimeMillis()),
        )
        setResult(RESULT_OK, Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, widgetId))
        finish()
    }
}
