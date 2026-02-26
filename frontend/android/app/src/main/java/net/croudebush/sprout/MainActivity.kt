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
