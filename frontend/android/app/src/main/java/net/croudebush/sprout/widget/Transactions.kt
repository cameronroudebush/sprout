package net.croudebush.sprout.widget

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import net.croudebush.sprout.R
import androidx.core.net.toUri
import net.croudebush.sprout.MainActivity
import java.text.SimpleDateFormat
import android.graphics.Color
import java.util.*
import androidx.core.graphics.toColorInt

class Transactions : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = WidgetUtils.getWidgetData(context)
        val transactions = widgetData?.optJSONArray("recentTransactions")
        val sdf = SimpleDateFormat("MMM dd, h:mm a", Locale.getDefault())
        val currentTimestamp = sdf.format(Date()).replace("AM", "am").replace("PM", "pm")

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.transactions)
            views.setEmptyView(R.id.widget_transactions_list, R.id.widget_empty_view)

            if (widgetData != null) {
                val bgColor = widgetData.optString("bgColor", "#141A1F").toColorInt()
                val txtColor = widgetData.optString("txtColor", "#FFFFFF").toColorInt()
                val txtMuted = widgetData.optString("txtColorMuted", "#A0A0A0").toColorInt()

                // Apply Theme to Container
                views.setInt(R.id.widget_root, "setBackgroundColor", bgColor)
                views.setTextColor(R.id.widget_title, txtColor)
                views.setTextColor(R.id.widget_last_updated, txtMuted)
                views.setTextColor(R.id.widget_empty_view, txtMuted)
            }

            val clickIntent = Intent(context, MainActivity::class.java)
            val clickPendingIntent = PendingIntent.getActivity(
                context, 0, clickIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setPendingIntentTemplate(R.id.widget_transactions_list, clickPendingIntent)
            views.setOnClickPendingIntent(R.id.widget_root, clickPendingIntent)

            val intent = Intent(context, TransactionsWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = toUri(Intent.URI_INTENT_SCHEME).toUri()
            }
            views.setRemoteAdapter(R.id.widget_transactions_list, intent)

            // Commit the structural changes to the Launcher first
            appWidgetManager.updateAppWidget(appWidgetId, views)

            val headerViews = RemoteViews(context.packageName, R.layout.transactions)

            val timestamp = widgetData?.optString("updateTime")?.takeIf { it.isNotEmpty() }
                ?: currentTimestamp
            headerViews.setTextViewText(R.id.widget_last_updated, timestamp)
            headerViews.setViewVisibility(R.id.widget_last_updated, View.VISIBLE)

            appWidgetManager.partiallyUpdateAppWidget(appWidgetId, headerViews)

            appWidgetManager.notifyAppWidgetViewDataChanged(
                appWidgetId,
                R.id.widget_transactions_list
            )
        }
    }
}