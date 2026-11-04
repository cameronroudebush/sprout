package net.croudebush.sprout.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import androidx.core.graphics.toColorInt
import net.croudebush.sprout.MainActivity
import net.croudebush.sprout.R

class Portfolio : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val rootData = WidgetUtils.getWidgetData(context)
        val data = rootData?.optJSONObject("data")
        val theme = rootData?.optJSONObject("theme")
        val failureMessage = rootData?.optString("failureMessage", null)
        val clickIntent = PendingIntent.getActivity(
            context,
            0,
            Intent(context, MainActivity::class.java),
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.portfolio)
            views.setOnClickPendingIntent(R.id.widget_root, clickIntent)

            if (theme != null) {
                val bgColor = theme.optString("bgColor", "#141A1F").toColorInt()
                val mutedColor = theme.optString("txtColorMuted", "#A0A0A0").toColorInt()
                val portfolioColor = theme.optString("portfolioStatusColor", "#00FF00").toColorInt()

                views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)
                views.setTextColor(R.id.widget_portfolio_column_label, mutedColor)
                views.setTextColor(R.id.widget_portfolio_percent, portfolioColor)
                views.setTextColor(R.id.widget_portfolio_change, portfolioColor)
                views.setTextColor(R.id.widget_last_updated, mutedColor)
                views.setTextColor(R.id.widget_empty_state, mutedColor)
                listOf(
                    R.id.widget_index_sp500_label,
                    R.id.widget_index_djia_label,
                    R.id.widget_index_nasdaq_label,
                ).forEach { views.setTextColor(it, mutedColor) }
            }

            if (data == null || data.length() == 0) {
                views.setViewVisibility(R.id.widget_header, View.GONE)
                views.setViewVisibility(R.id.widget_data_container, View.GONE)
                views.setViewVisibility(R.id.widget_empty_state, View.VISIBLE)
                views.setTextViewText(R.id.widget_empty_state, failureMessage ?: context.getString(R.string.widget_no_data))
            } else {
                views.setViewVisibility(R.id.widget_header, View.VISIBLE)
                views.setViewVisibility(R.id.widget_data_container, View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty_state, View.GONE)
                views.setViewVisibility(R.id.widget_last_updated, View.VISIBLE)
                views.setTextViewText(R.id.widget_last_updated, data.optString("updateTime", ""))

                views.setTextViewText(
                    R.id.widget_portfolio_percent,
                    data.optString("portfolioChangePercent", "+0.00%")
                )
                views.setTextViewText(
                    R.id.widget_portfolio_change,
                    data.optString("portfolioChange", "+$0.00")
                )

                val indices = data.optJSONArray("majorIndices")
                val indexViews = listOf(
                    Triple(
                        R.id.widget_index_sp500,
                        R.id.widget_index_sp500_label,
                        R.id.widget_index_sp500_percent,
                    ),
                    Triple(
                        R.id.widget_index_djia,
                        R.id.widget_index_djia_label,
                        R.id.widget_index_djia_percent,
                    ),
                    Triple(
                        R.id.widget_index_nasdaq,
                        R.id.widget_index_nasdaq_label,
                        R.id.widget_index_nasdaq_percent,
                    ),
                )
                val changeViews = listOf(
                    R.id.widget_index_sp500_change,
                    R.id.widget_index_djia_change,
                    R.id.widget_index_nasdaq_change,
                )
                indexViews.forEachIndexed { index, (columnId, labelId, percentId) ->
                    val indexData = indices?.optJSONObject(index)
                    if (indexData == null) {
                        views.setViewVisibility(columnId, View.GONE)
                    } else {
                        views.setViewVisibility(columnId, View.VISIBLE)
                        views.setTextViewText(labelId, indexData.optString("name", ""))
                        views.setTextViewText(percentId, indexData.optString("changePercent", "—"))
                        views.setTextViewText(changeViews[index], indexData.optString("change", "—"))
                        val indexColor = indexData.optString("statusColor", "#00FF00").toColorInt()
                        views.setTextColor(percentId, indexColor)
                        views.setTextColor(changeViews[index], indexColor)
                    }
                }
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
