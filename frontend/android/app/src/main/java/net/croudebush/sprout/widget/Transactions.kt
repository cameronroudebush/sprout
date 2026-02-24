package net.croudebush.sprout.widget

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import net.croudebush.sprout.R
import androidx.core.net.toUri

class Transactions : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = WidgetUtils.getWidgetData(context)
        val transactions = widgetData?.optJSONArray("recentTransactions")
        val hasData = transactions != null && transactions.length() > 0

        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.transactions)
            views.setEmptyView(R.id.widget_transactions_list, R.id.widget_empty_view)
            if (hasData) {
                val timestamp = widgetData?.optString("updateTime", "") ?: ""
                views.setTextViewText(R.id.widget_last_updated, timestamp)
                views.setViewVisibility(R.id.widget_last_updated, View.VISIBLE)
            } else {
                views.setViewVisibility(R.id.widget_last_updated, View.GONE)
            }
            val intent = Intent(context, TransactionsWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = toUri(Intent.URI_INTENT_SCHEME).toUri()
            }
            views.setRemoteAdapter(R.id.widget_transactions_list, intent)
            appWidgetManager.updateAppWidget(appWidgetId, views)
            appWidgetManager.notifyAppWidgetViewDataChanged(
                appWidgetId,
                R.id.widget_transactions_list
            )
        }
    }
}