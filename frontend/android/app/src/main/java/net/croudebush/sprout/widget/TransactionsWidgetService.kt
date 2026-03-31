package net.croudebush.sprout.widget

import android.content.Context
import android.content.Intent
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import androidx.core.content.ContextCompat
import net.croudebush.sprout.R
import android.graphics.Color
import org.json.JSONArray
import androidx.core.graphics.toColorInt
import org.json.JSONObject

class TransactionsWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return TransactionsRemoteViewsFactory(this.applicationContext)
    }
}

class TransactionsRemoteViewsFactory(private val context: Context) :
    RemoteViewsService.RemoteViewsFactory {
    private var transactions = JSONArray()
    private var themeData: JSONObject? = null

    override fun onDataSetChanged() {
        val root = WidgetUtils.getWidgetData(context)
        themeData = root?.optJSONObject("theme")
        val dataObj = root?.optJSONObject("data")
        transactions = dataObj?.optJSONArray("recentTransactions") ?: JSONArray()
    }

    override fun getViewAt(position: Int): RemoteViews {
        val item = transactions.getJSONObject(position)
        val views = RemoteViews(context.packageName, R.layout.transaction_item)

        // Get Theme Colors from the parent data
        val txtColor = themeData?.optString("txtColor", "#FFFFFF")?.toColorInt()
        val txtMuted = themeData?.optString("txtColorMuted", "#A0A0A0")?.toColorInt()
        val amountColor = item.optString("amountColor", "#FF0000").toColorInt()

        val merchant = item.optString("merchant", "Unknown")
        val category = item.optString("category", "General")
        val amountText = item.optString("amount", "$0.00")
        val date = item.optString("date", "")
        val amountNumeric = item.optDouble("amountNumeric", 0.0)
        val isPending = item.optBoolean("pending", false)
        val id = item.optString("id", "")

        if (txtColor != null) {
            views.setTextColor(R.id.item_merchant_name, txtColor)
        }
        if (txtMuted != null) {
            views.setTextColor(R.id.item_category, txtMuted)
            views.setTextColor(R.id.item_date, txtMuted)
            views.setTextColor(R.id.item_pending, txtMuted)
        }
        views.setTextColor(R.id.item_amount, amountColor)

        val fillInIntent = Intent()
        fillInIntent.putExtra("transaction_id", id)
        views.setOnClickFillInIntent(R.id.transaction_item_root, fillInIntent)

        views.setTextViewText(R.id.item_merchant_name, merchant)
        views.setTextViewText(R.id.item_category, category)
        views.setTextViewText(R.id.item_amount, amountText)
        views.setTextViewText(R.id.item_date, date)

        if (isPending) {
            views.setViewVisibility(R.id.item_pending, View.VISIBLE)
        } else {
            views.setViewVisibility(R.id.item_pending, View.GONE)
        }

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