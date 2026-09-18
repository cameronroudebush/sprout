package net.croudebush.sprout.widget

import android.content.Context
import android.content.Intent
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.util.Base64
import android.view.View
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import androidx.core.content.ContextCompat
import androidx.core.graphics.toColorInt
import net.croudebush.sprout.R
import org.json.JSONArray
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

        // Theme colors passed from Flutter
        val txtColor = themeData?.optString("txtColor", "#FFFFFF")?.toColorInt()
        val txtMuted = themeData?.optString("txtColorMuted", "#A0A0A0")?.toColorInt()
        val cardColor = themeData?.optString("cardColor", "#1E262E")?.toColorInt()
        val amountColor = item.optString("amountColor", "#FF0000").toColorInt()

        val merchant = item.optString("merchant", "Unknown")
        val category = item.optString("category", "General")
        val amountText = item.optString("amount", "$0.00")
        val date = item.optString("date", "")
        val amountNumeric = item.optDouble("amountNumeric", 0.0)
        val isPending = item.optBoolean("pending", false)
        val id = item.optString("id", "")
        val iconBase64 = item.optString("iconBase64", null)

        // Icon Rendering
        if (!iconBase64.isNullOrEmpty()) {
            try {
                val decodedBytes = Base64.decode(iconBase64, Base64.DEFAULT)
                val bitmap = BitmapFactory.decodeByteArray(decodedBytes, 0, decodedBytes.size)
                if (bitmap != null) {
                    views.setImageViewBitmap(R.id.item_merchant_icon, bitmap)
                } else {
                    views.setImageViewResource(R.id.item_merchant_icon, android.R.drawable.ic_menu_report_image)
                }
            } catch (e: Exception) {
                views.setImageViewResource(R.id.item_merchant_icon, android.R.drawable.ic_menu_report_image)
            }
        } else {
            views.setImageViewResource(R.id.item_merchant_icon, android.R.drawable.ic_menu_report_image)
        }

        // Apply Pending Highlight vs Default Row background
        if (isPending) {
            views.setViewVisibility(R.id.item_pending, View.VISIBLE)

            // Subtle 10% white overlay background
            val highlightOverlay = Color.argb(0x1A, 0xFF, 0xFF, 0xFF) // ~10% white overlay
            views.setInt(R.id.transaction_item_root, "setBackgroundColor", highlightOverlay)
        } else {
            views.setViewVisibility(R.id.item_pending, View.GONE)
            views.setInt(R.id.transaction_item_root, "setBackgroundColor", Color.TRANSPARENT)
        }

        // Text Colors
        if (txtColor != null) {
            views.setTextColor(R.id.item_merchant_name, txtColor)
        }
        if (txtMuted != null) {
            views.setTextColor(R.id.item_category, txtMuted)
            views.setTextColor(R.id.item_date, txtMuted)
            views.setTextColor(R.id.item_pending, txtMuted)
        }

        // Fill-in Intent for list item taps
        val fillInIntent = Intent().apply {
            data = Uri.parse("sprout:///transactions/$id")
            putExtra("transaction_id", id)
        }
        views.setOnClickFillInIntent(R.id.transaction_item_root, fillInIntent)

        views.setTextViewText(R.id.item_merchant_name, merchant)
        views.setTextViewText(R.id.item_category, category)
        views.setTextViewText(R.id.item_amount, amountText)
        views.setTextViewText(R.id.item_date, date)

        // Amount coloring (Positive vs Negative)
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