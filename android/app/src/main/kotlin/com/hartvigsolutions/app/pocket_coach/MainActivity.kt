package com.hartvigsolutions.pocket_coach

import android.content.Context
import android.content.res.Configuration
import androidx.appcompat.app.AppCompatDelegate
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.hartvigsolutions.app/theme"
    private val PREFS_NAME = "theme_prefs"
    private val KEY_THEME = "selected_theme"

    override fun attachBaseContext(newBase: Context) {
        val prefs = newBase.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val theme = prefs.getString(KEY_THEME, "system")
        
        val mode = when (theme) {
            "dark" -> Configuration.UI_MODE_NIGHT_YES
            "light" -> Configuration.UI_MODE_NIGHT_NO
            else -> Configuration.UI_MODE_NIGHT_UNDEFINED
        }

        if (mode != Configuration.UI_MODE_NIGHT_UNDEFINED) {
            val config = Configuration(newBase.resources.configuration)
            config.uiMode = (config.uiMode and Configuration.UI_MODE_NIGHT_MASK.inv()) or mode
            val context = newBase.createConfigurationContext(config)
            super.attachBaseContext(context)
        } else {
            super.attachBaseContext(newBase)
        }
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "setTheme") {
                val theme = call.argument<String>("theme")
                applyTheme(theme)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun applyTheme(theme: String?) {
        val prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val currentTheme = prefs.getString(KEY_THEME, "system")
        
        if (currentTheme != theme) {
            prefs.edit().putString(KEY_THEME, theme).apply()
            
            val mode = when (theme) {
                "dark" -> AppCompatDelegate.MODE_NIGHT_YES
                "light" -> AppCompatDelegate.MODE_NIGHT_NO
                else -> AppCompatDelegate.MODE_NIGHT_FOLLOW_SYSTEM
            }
            
            AppCompatDelegate.setDefaultNightMode(mode)
            // Recreate activity to apply the new configuration context
            recreate()
        }
    }
}
