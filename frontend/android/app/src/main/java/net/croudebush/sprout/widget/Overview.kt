package net.croudebush.sprout.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.view.View
import android.widget.RemoteViews
import net.croudebush.sprout.MainActivity
import net.croudebush.sprout.R
import androidx.core.graphics.toColorInt

class Overview : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val data = WidgetUtils.getWidgetData(context)
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
                val timestamp = data.optString("updateTime", "")
                val numericChange = data.optDouble("numericChange", 0.0)

                // Color Hexes from Flutter
                val bgColor = data.optString("bgColor", "#141A1F")
                val txtColor = data.optString("txtColor", "#FFFFFF")
                val txtMuted = data.optString("txtColorMuted", "#A0A0A0")
                val statusColor = data.optString("statusColor", "#00FF00")

                // Apply Theme Colors
                val parsedBg = bgColor.toColorInt()
                val parsedTxt = txtColor.toColorInt()
                val parsedMuted = txtMuted.toColorInt()
                val parsedStatus = statusColor.toColorInt()

                // Background tint (Requires API 21+)
                views.setInt(R.id.widget_root, "setBackgroundColor", parsedBg)

                // Text Colors
                views.setTextColor(R.id.widget_nw_value, parsedTxt)
                views.setTextColor(R.id.widget_label_networth, parsedMuted)
                views.setTextColor(R.id.widget_last_updated, parsedMuted)
                views.setTextColor(R.id.empty_state_container, parsedMuted)

                // Status Color (Gains/Losses)
                views.setTextColor(R.id.widget_nw_change, parsedStatus)

                // Set Content
                views.setTextViewText(R.id.widget_nw_value, netWorth)
                val changeStr =
                    "${data.optString("changeAmount")} (${data.optString("changePercent")})"
                views.setTextViewText(R.id.widget_nw_change, changeStr)
                views.setTextViewText(R.id.widget_last_updated, timestamp)

                // Icon logic
                val isPositive = numericChange >= 0
                views.setImageViewResource(
                    R.id.widget_nw_change_icon,
                    if (isPositive) android.R.drawable.arrow_up_float else android.R.drawable.arrow_down_float
                )
                views.setInt(R.id.widget_nw_change_icon, "setColorFilter", parsedStatus)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}