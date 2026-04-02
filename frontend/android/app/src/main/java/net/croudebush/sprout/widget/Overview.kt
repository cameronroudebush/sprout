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
        val rootData = WidgetUtils.getWidgetData(context)
        val dataObj = rootData?.optJSONObject("data")
        val themeObj = rootData?.optJSONObject("theme")

        val pendingIntent = PendingIntent.getActivity(
            context, 0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.overview)
            views.setOnClickPendingIntent(R.id.widget_root, pendingIntent)

            // Apply theme
            if (themeObj != null) {
                val bgColor = themeObj.optString("bgColor", "#141A1F").toColorInt()
                val txtColor = themeObj.optString("txtColor", "#FFFFFF").toColorInt()
                val txtMuted = themeObj.optString("txtColorMuted", "#A0A0A0").toColorInt()
                val statusColor = themeObj.optString("statusColor", "#00FF00").toColorInt()

                // Background
                views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)

                // Text Colors
                views.setTextColor(R.id.widget_nw_value, txtColor)
                views.setTextColor(R.id.widget_label_networth, txtMuted)
                views.setTextColor(R.id.widget_last_updated, txtMuted)
                
                // Ensure empty state matches theme
                views.setTextColor(R.id.empty_state_container, txtMuted)
                
                // Store status color for data use below
                views.setTextColor(R.id.widget_nw_change, statusColor)
            }

            // Handle Data Display
            if (dataObj == null || dataObj.length() == 0) {
                views.setViewVisibility(R.id.data_container, View.GONE)
                views.setViewVisibility(R.id.empty_state_container, View.VISIBLE)
                views.setViewVisibility(R.id.widget_last_updated, View.GONE)
            } else {
                views.setViewVisibility(R.id.data_container, View.VISIBLE)
                views.setViewVisibility(R.id.empty_state_container, View.GONE)
                views.setViewVisibility(R.id.widget_last_updated, View.VISIBLE)

                val netWorth = dataObj.optString("netWorth", "$0.00")
                val timestamp = dataObj.optString("updateTime", "")
                val dayRange = dataObj.optString("dayRange", "")
                val numericChange = dataObj.optDouble("numericChange", 0.0)
                val changeAmount = dataObj.optString("changeAmount", "$0.00")
                val changePercent = dataObj.optString("changePercent", "0.00%")
                
                // Get status color from theme or fallback
                val parsedStatus = themeObj?.optString("statusColor", "#00FF00")?.toColorInt() ?: Color.GREEN

                // Set Content
                views.setTextViewText(R.id.widget_nw_value, netWorth)
                val changeStr = "$changeAmount ($changePercent) $dayRange"
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