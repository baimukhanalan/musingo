package com.muslingo.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MuslingoAyahWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        val entry = todaysEntry(widgetData.getString("daily_ayah_payload", "[]") ?: "[]")
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.muslingo_ayah_widget).apply {
                setOnClickPendingIntent(
                    R.id.ayah_widget_container,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
                )
                setTextViewText(R.id.ayah_widget_number, entry.number)
                setTextViewText(R.id.ayah_widget_arabic, entry.arabic)
                setTextViewText(R.id.ayah_widget_translation, entry.translation)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun todaysEntry(payload: String): WidgetEntry {
        return try {
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val entries = JSONArray(payload)
            for (index in 0 until entries.length()) {
                val item = entries.getJSONObject(index)
                val entry = WidgetEntry(
                    number = "${item.optString("title", "Muslingo")} · №${item.optInt("number")}",
                    arabic = item.optString("arabic"),
                    translation = item.optString("translation"),
                )
                if (item.optString("date") == today) return entry
            }
            emptyEntry()
        } catch (_: Exception) {
            emptyEntry()
        }
    }

    private fun emptyEntry() = WidgetEntry(
        number = "Muslingo",
        arabic = "Аят дня готовится",
        translation = "Открой приложение, чтобы обновить виджет.",
    )
}

private data class WidgetEntry(
    val number: String,
    val arabic: String,
    val translation: String,
)
