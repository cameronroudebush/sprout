package net.croudebush.sprout.widget

import android.content.Context
import org.json.JSONObject
import java.text.SimpleDateFormat
import es.antonborri.home_widget.HomeWidgetPlugin
import java.util.Date
import java.util.Locale

object WidgetUtils {
    public const val PREFS_NAME = "widget_prefs"
    public const val JSON_KEY = "widget_json"

    /**
     * Gets the widget data from shared preferences
     */
    fun getWidgetData(context: Context): JSONObject? {
        try {
            // Read from the SharedPreferences managed by home_widget
            val prefs = HomeWidgetPlugin.getData(context)
            val jsonString = prefs.getString("widget_data", null)
            
            if (jsonString != null) {
                return JSONObject(jsonString)
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }
        return null
    }
}