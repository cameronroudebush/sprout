package net.croudebush.sprout.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import net.croudebush.sprout.R

class Transactions : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // Grab data using the shared logic
        val data = WidgetUtils.getWidgetData(context)
        val transactions = data?.optJSONArray("recentTransactions")
        val hasData = transactions != null && transactions.length() > 0
        val timestamp = WidgetUtils.getFormattedTimestamp()

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.transactions)

            if (hasData) {
                views.setViewVisibility(R.id.widget_transactions_list, View.VISIBLE)
                views.setViewVisibility(R.id.widget_empty_view, View.GONE)
                views.setViewVisibility(R.id.widget_last_updated, View.VISIBLE)
                views.setTextViewText(R.id.widget_last_updated, timestamp)

                // Setup the remote adapter if we have data
                val intent = Intent(context, TransactionsWidgetService::class.java)
                views.setRemoteAdapter(R.id.widget_transactions_list, intent)
            } else {
                views.setViewVisibility(R.id.widget_transactions_list, View.GONE)
                views.setViewVisibility(R.id.widget_empty_view, View.VISIBLE)
                views.setViewVisibility(R.id.widget_last_updated, View.GONE)
            }

            appWidgetManager.updateAppWidget(appWidgetId, views)

            // Force a list data refresh if we have data
            if (hasData) {
                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetId, R.id.widget_transactions_list)
            }
        }
    }
}