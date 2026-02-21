package net.croudebush.sprout.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import androidx.core.content.ContextCompat
import net.croudebush.sprout.MainActivity
import net.croudebush.sprout.R

class Overview : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Grab data using shared logic
        val data = WidgetUtils.getWidgetData(context)
        val timestamp = WidgetUtils.getFormattedTimestamp()

        // Setup the base click intent
        val pendingIntent = PendingIntent.getActivity(
            context, 0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.overview)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            if (data == null || data.length() == 0) {
                views.setViewVisibility(R.id.data_container, View.GONE)
                views.setViewVisibility(R.id.empty_state_container, View.VISIBLE)
                views.setViewVisibility(R.id.widget_last_updated, View.GONE)
            } else {
                views.setViewVisibility(R.id.data_container, View.VISIBLE)
                views.setViewVisibility(R.id.empty_state_container, View.GONE)
                views.setViewVisibility(R.id.widget_last_updated, View.VISIBLE)

                val netWorth = data.optString("netWorth", "$0.00")
                val numericChange = data.optDouble("numericChange", 0.0)
                val isPositive = numericChange >= 0

                views.setTextViewText(R.id.widget_nw_value, netWorth)
                views.setTextViewText(R.id.widget_nw_change,
                    "${data.optString("changeAmount")} (${data.optString("changePercent")}) ${data.optString("dayRange")}")

                // Unified styling
                val color = ContextCompat.getColor(context,
                    if (isPositive) R.color.sprout_accent_green else android.R.color.holo_red_light)

                views.setTextColor(R.id.widget_nw_change, color)
                views.setImageViewResource(R.id.widget_nw_change_icon,
                    if (isPositive) android.R.drawable.arrow_up_float else android.R.drawable.arrow_down_float)
                views.setInt(R.id.widget_nw_change_icon, "setColorFilter", color)
                views.setTextViewText(R.id.widget_last_updated, timestamp)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}