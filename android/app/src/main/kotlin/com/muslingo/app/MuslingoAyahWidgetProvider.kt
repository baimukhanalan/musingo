package com.muslingo.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
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
        val locale = widgetData.getString("widget_locale", "ru") ?: "ru"
        val direction = if (locale == "ar") View.LAYOUT_DIRECTION_RTL else View.LAYOUT_DIRECTION_LTR
        val entry = todaysEntry(widgetData.getString("daily_ayah_payload", "[]") ?: "[]", locale)
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.muslingo_ayah_widget).apply {
                setInt(R.id.ayah_widget_container, "setLayoutDirection", direction)
                setOnClickPendingIntent(
                    R.id.ayah_widget_container,
                    HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("muslingo:///daily-ayah")),
                )
                setTextViewText(R.id.ayah_widget_number, entry.number)
                setTextViewText(R.id.ayah_widget_arabic, entry.arabic)
                setTextViewText(R.id.ayah_widget_translation, entry.translation)
                setTextViewText(R.id.ayah_widget_coach, entry.coachLine)
                setViewVisibility(R.id.ayah_widget_translation, if (entry.translation.isEmpty()) View.GONE else View.VISIBLE)
                setViewVisibility(R.id.ayah_widget_coach, if (entry.coachLine.isEmpty()) View.GONE else View.VISIBLE)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun todaysEntry(payload: String, locale: String): WidgetEntry {
        return try {
            val today = SimpleDateFormat("yyyy-MM-dd", Locale.US).format(Date())
            val entries = JSONArray(payload)
            for (index in 0 until entries.length()) {
                val item = entries.getJSONObject(index)
                val entry = WidgetEntry(
                    number = "${item.optString("title", "Muslingo")} · №${item.optInt("number")}",
                    arabic = item.optString("arabic"),
                    translation = item.optString("translation"),
                    coachLine = item.optString("coachLine"),
                )
                if (item.optString("date") == today) return entry
            }
            emptyEntry(locale)
        } catch (_: Exception) {
            emptyEntry(locale)
        }
    }

    private fun emptyEntry(locale: String) = WidgetEntry(
        number = "Muslingo",
        arabic = when (locale) {
            "ar" -> "جارٍ إعداد آية اليوم"
            "kk" -> "Күн аяты дайындалуда"
            "en" -> "Your daily ayah is getting ready"
            else -> "Аят дня готовится"
        },
        translation = when (locale) {
            "ar" -> "افتح Muslingo لتحديث الأداة."
            "kk" -> "Виджетті жаңарту үшін Muslingo қолданбасын аш."
            "en" -> "Open Muslingo to refresh the widget."
            else -> "Открой приложение, чтобы обновить виджет."
        },
        coachLine = "",
    )
}

private data class WidgetEntry(
    val number: String,
    val arabic: String,
    val translation: String,
    val coachLine: String,
)
