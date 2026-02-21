package net.croudebush.sprout.widget

import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import androidx.core.content.ContextCompat
import net.croudebush.sprout.R
import org.json.JSONArray

class TransactionsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TransactionsRemoteViewsFactory(this.applicationContext)
    }
}

class TransactionsRemoteViewsFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {
    private var transactions = JSONArray()

    override fun onDataSetChanged() {
        // Fetch fresh data from shared prefs
        val data = WidgetUtils.getWidgetData(context)
        transactions = data?.optJSONArray("recentTransactions") ?: JSONArray()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val item = transactions.getJSONObject(position)
        val views = RemoteViews(context.packageName, R.layout.transaction_item)

        // Data Binding
        val merchant = item.optString("merchant", "Unknown")
        val category = item.optString("category", "General")
        val amountText = item.optString("amount", "$0.00")
        val date = item.optString("date", "")
        val amountNumeric = item.optDouble("amountNumeric", 0.0)

        views.setTextViewText(R.id.item_merchant_name, merchant)
        views.setTextViewText(R.id.item_category, category.uppercase())
        views.setTextViewText(R.id.item_amount, amountText)
        views.setTextViewText(R.id.item_date, date)

        // Color logic based on numeric value
        val isPositive = amountNumeric >= 0
        val colorRes = if (isPositive) {
            R.color.sprout_accent_green
        } else {
            android.R.color.holo_red_light
        }
        views.setTextColor(R.id.item_amount, ContextCompat.getColor(context, colorRes))

        return views
    }

    override fun getCount(): Int = transactions.length()
    override fun getViewTypeCount(): Int = 1
    override fun onCreate() {}
    override fun onDestroy() {}
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
    override fun getLoadingView(): RemoteViews? = null
}