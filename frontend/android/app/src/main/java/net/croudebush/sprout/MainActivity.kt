package net.croudebush.sprout

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import androidx.core.content.edit
import net.croudebush.sprout.widget.Overview
import net.croudebush.sprout.widget.Transactions
import net.croudebush.sprout.widget.WidgetUtils

class MainActivity : FlutterFragmentActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        setupSecurityMethodChannel(flutterEngine)
        setupWidgetMethodChannel(flutterEngine)
    }

    /**
     * Setups the method channel so the flutter app can communicate to update widget data directly.
     */
    private fun setupWidgetMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "net.croudebush.sprout/widget"
        ).setMethodCallHandler { call, result ->
            if (call.method == "updateData") {
                val json = call.argument<String>("json")

                // Save the data using your existing setup
                val prefs = getSharedPreferences(WidgetUtils.PREFS_NAME, Context.MODE_PRIVATE)
                prefs.edit { putString(WidgetUtils.JSON_KEY, json) }

                val context: Context = this
                val appWidgetManager = AppWidgetManager.getInstance(context)

                // Update overview widget
                val overviewIds = appWidgetManager.getAppWidgetIds(
                    ComponentName(context, Overview::class.java)
                )
                if (overviewIds.isNotEmpty()) {
                    val overviewIntent = Intent(context, Overview::class.java).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, overviewIds)
                    }
                    sendBroadcast(overviewIntent)
                }

                // Update transactions widget
                val transactionIds = appWidgetManager.getAppWidgetIds(
                    ComponentName(context, Transactions::class.java)
                )
                if (transactionIds.isNotEmpty()) {
                    val transactionIntent = Intent(context, Transactions::class.java).apply {
                        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
                        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, transactionIds)
                    }
                    sendBroadcast(transactionIntent)
                    appWidgetManager.notifyAppWidgetViewDataChanged(
                        transactionIds,
                        R.id.widget_transactions_list
                    )
                }

                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    /**
     * Setups the method channel so the flutter app can communicate to allow us to set FLAG_SECURE to hide the app when in the background.
     */
    private fun setupSecurityMethodChannel(flutterEngine: FlutterEngine) {
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "net.croudebush.sprout/security"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "enableAppSecurity" -> {
                    window.setFlags(
                        WindowManager.LayoutParams.FLAG_SECURE,
                        WindowManager.LayoutParams.FLAG_SECURE
                    )
                    result.success(null)
                }

                "disableAppSecurity" -> {
                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }
}
