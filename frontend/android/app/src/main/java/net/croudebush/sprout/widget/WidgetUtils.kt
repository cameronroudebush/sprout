package net.croudebush.sprout.widget

import android.content.Context
import org.json.JSONObject
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object WidgetUtils {
    public const val PREFS_NAME = "widget_prefs"
    public const val JSON_KEY = "widget_json"

    /**
     * Gets the widget data from shared preferences
     */
    fun getWidgetData(context: Context): JSONObject? {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val jsonString = prefs.getString(JSON_KEY, null) ?: return null
        return try {
            JSONObject(jsonString)
        } catch (e: Exception) {
            null
        }
    }
}