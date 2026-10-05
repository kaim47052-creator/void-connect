package dev.voidconnect.void_connect

import android.content.ActivityNotFoundException
import android.content.Intent
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val libraryPreferences by lazy {
        getSharedPreferences("void_connect_app_library", MODE_PRIVATE)
    }
    private val settingsPreferences by lazy {
        getSharedPreferences("void_connect_settings", MODE_PRIVATE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "void_connect/settings",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "getLanguage" -> result.success(settingsPreferences.getString(KEY_LANGUAGE, null))
                "setLanguage" -> {
                    val languageCode = call.argument<String>("languageCode")
                    if (languageCode == null || languageCode !in SUPPORTED_LANGUAGES) {
                        result.error("invalid_argument", "Unsupported language", null)
                    } else {
                        settingsPreferences.edit().putString(KEY_LANGUAGE, languageCode).apply()
                        result.success(null)
                    }
                }
                else -> result.notImplemented()
            }
        }
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "void_connect/app_library",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "listApps" -> result.success(listLaunchableApps())
                "getSavedApps" -> result.success(
                    libraryPreferences.getStringSet(KEY_SAVED_APPS, emptySet())
                        .orEmpty()
                        .sorted(),
                )
                "addApp" -> updateSavedApp(call.argument("id"), add = true, result)
                "removeApp" -> updateSavedApp(call.argument("id"), add = false, result)
                "launchApp" -> launchApp(call.argument("id"), result)
                else -> result.notImplemented()
            }
        }
    }

    private fun listLaunchableApps(): List<Map<String, String>> {
        val intent = Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER)
        val matches = packageManager.queryIntentActivities(intent, 0)
        return matches
            .asSequence()
            .filter { it.activityInfo.packageName != packageName }
            .distinctBy { it.activityInfo.packageName }
            .map {
                mapOf(
                    "id" to it.activityInfo.packageName,
                    "name" to (it.loadLabel(packageManager)?.toString()
                        ?: it.activityInfo.packageName),
                )
            }
            .sortedBy { it["name"]?.lowercase() }
            .toList()
    }

    private fun updateSavedApp(
        id: String?,
        add: Boolean,
        result: MethodChannel.Result,
    ) {
        if (id.isNullOrBlank()) {
            result.error("invalid_argument", "App identifier is required", null)
            return
        }
        val saved = libraryPreferences.getStringSet(KEY_SAVED_APPS, emptySet())
            .orEmpty()
            .toMutableSet()
        if (add) saved.add(id) else saved.remove(id)
        libraryPreferences.edit().putStringSet(KEY_SAVED_APPS, saved).apply()
        result.success(null)
    }

    private fun launchApp(id: String?, result: MethodChannel.Result) {
        if (id.isNullOrBlank()) {
            result.error("invalid_argument", "App identifier is required", null)
            return
        }
        try {
            val intent = packageManager.getLaunchIntentForPackage(id)
            if (intent == null) {
                result.error("app_not_found", "No launcher activity for $id", null)
                return
            }
            startActivity(intent)
            result.success(true)
        } catch (error: ActivityNotFoundException) {
            result.error("app_not_found", error.message, null)
        } catch (error: SecurityException) {
            result.error("launch_failed", error.message, null)
        }
    }

    companion object {
        private const val KEY_SAVED_APPS = "saved_app_ids"
        private const val KEY_LANGUAGE = "language_code"
        private val SUPPORTED_LANGUAGES = setOf("ru", "en")
    }
}
