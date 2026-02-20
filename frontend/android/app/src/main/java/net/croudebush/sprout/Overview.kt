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

/**
 * Implementation of App Widget functionality.
 */
class Overview : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        // There may be multiple widgets active, so update all of them
        for (appWidgetId in appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId)
        }
    }

    override fun onEnabled(context: Context) {
        // Enter relevant functionality for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Enter relevant functionality for when the last widget is disabled
    }
}

internal fun updateAppWidget(
    context: Context,
    appWidgetManager: AppWidgetManager,
    appWidgetId: Int
) {
    // Construct the RemoteViews object
    val views = RemoteViews(context.packageName, R.layout.overview)

    // 1. Set up click intent to open the main app when clicked
    val intent = Intent(context, MainActivity::class.java)
    val pendingIntent = PendingIntent.getActivity(
        context, 0, intent, PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
    )
    views.setOnClickPendingIntent(R.id.widget_nw_value, pendingIntent)


    // ==========================================================
    // REAL DATA FETCHING IMPLEMENTATION NOTE:
    // In a real app, don't do heavy work here on the main thread.
    // Use WorkManager or Coroutines to fetch data from your DB repository,
    // then update the widget asynchronously.
    // ==========================================================

    // --- MOCK DATA FOR DEMONSTRATION ---
    val mockNetWorth = "$91,765.54"
    val mockChange = "+$2,370.29 (2.65%) 1 month"
    val isPositiveChange = true

    data class MockTrans(val payee: String, val date: String, val amount: String, val isIncome: Boolean)
    val transactions = listOf(
        MockTrans("Whole Foods", "Feb 16", "-$124.32", false),
        MockTrans("Spotify", "Feb 15", "-$11.99", false),
        MockTrans("Salary Deposit", "Feb 14", "+$3,200.00", true)
    )
    // ------------------------------------


    // 2. Populate Net Worth Section
    views.setTextViewText(R.id.widget_nw_value, mockNetWorth)
    views.setTextViewText(R.id.widget_nw_change, mockChange)

    // Set color/icon based on positive/negative change
    val changeColor = if (isPositiveChange) R.color.sprout_accent_green else android.R.color.holo_red_light
    views.setTextColor(R.id.widget_nw_change, ContextCompat.getColor(context, changeColor))
    // Note: Changing the arrow icon drawable dynamically requires a bit more work with RemoteViews setImageViewResource


    // 3. Populate Transaction Slots
    // We loop through the layout slots (trans_1, trans_2, trans_3) and fill them if data exists.
//    val slotIds = listOf(
//        Triple(R.id.trans_item_1, R.id.trans_1_payee, R.id.trans_1_amount),
//        Triple(R.id.trans_item_2, R.id.trans_2_payee, R.id.trans_2_amount),
//        Triple(R.id.trans_item_3, R.id.trans_3_payee, R.id.trans_3_amount),
//    )
//
//    slotIds.forEachIndexed { index, (containerId, payeeId, amountId) ->
//        if (index < transactions.size) {
//            val tx = transactions[index]
//            views.setViewVisibility(containerId, View.VISIBLE)
//            views.setTextViewText(payeeId, tx.payee)
//            views.setTextViewText(amountId, tx.amount)
//
//            // Style income differently
//            val amountColor = if (tx.isIncome) R.color.sprout_accent_green else R.color.sprout_text_primary
//            views.setTextColor(amountId, ContextCompat.getColor(context, amountColor))
//
//        } else {
//            // Hide unused slots if fewer than 3 transactions exist
//            views.setViewVisibility(containerId, View.GONE)
//        }
//    }


    // Instruct the widget manager to update the widget
    appWidgetManager.updateAppWidget(appWidgetId, views)
}

//internal fun updateAppWidget(
//    context: Context,
//    appWidgetManager: AppWidgetManager,
//    appWidgetId: Int
//) {
//    // Construct the RemoteViews object
//    val views = RemoteViews(context.packageName, R.layout.overview)
//
//    // 1. Set up click intent to open the main app
//    // ... (this part remains the same)
//
//    // ==========================================================
//    // FETCHING REAL DATA FROM SHARED PREFERENCES
//    // ==========================================================
//    val widgetData: SharedPreferences = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
//
//    val netWorth = widgetData.getString("net_worth", "---") // Default value if not found
//    val change = widgetData.getString("net_worth_change", "")
//
//    // --- MOCK DATA FOR TRANSACTIONS (for now) ---
//    // TODO: Replace this by also saving/retrieving transaction data from SharedPreferences
//    val isPositiveChange = change?.startsWith("+") ?: true
//    data class MockTrans(val payee: String, val date: String, val amount: String, val isIncome: Boolean)
//    val transactions = listOf(
//        MockTrans("Whole Foods", "Feb 16", "-$124.32", false),
//        MockTrans("Spotify", "Feb 15", "-$11.99", false),
//        MockTrans("Salary Deposit", "Feb 14", "+$3,200.00", true)
//    )
//    // ------------------------------------
//
//    // 2. Populate Net Worth Section with real data
//    views.setTextViewText(R.id.widget_nw_value, netWorth)
//    views.setTextViewText(R.id.widget_nw_change, change)
//
//    // Set color/icon based on positive/negative change
//    val changeColor = if (isPositiveChange) R.color.sprout_accent_green else android.R.color.holo_red_light
//    views.setTextColor(R.id.widget_nw_change, ContextCompat.getColor(context, changeColor))
//
//    // 3. Populate Transaction Slots (still using mock data)
//    // ... (this logic remains the same for now)
//
//    // Instruct the widget manager to update the widget
//    appWidgetManager.updateAppWidget(appWidgetId, views)
//}