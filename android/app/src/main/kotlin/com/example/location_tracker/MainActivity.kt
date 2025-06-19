package com.example.location_tracker

import android.content.Context
import android.content.Intent
import android.os.Build
//import androidx.work.ExistingPeriodicWorkPolicy
//import androidx.work.PeriodicWorkRequestBuilder
//import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
//import androidx.work.*


class MainActivity: FlutterActivity() {

    private val CHANNEL = "background_location_channel"

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        FlutterEngineCache.getInstance().put("shared_engine", flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
                call, result ->
            when (call.method) {
                "startService" -> {
                    val intent = Intent(this, ServiceLocation::class.java)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                        startForegroundService(intent)
                    }
//                    scheduleWorkManagerJob()
                    result.success(null)
                }
                "stopService" -> {
                    val intent = Intent(this, ServiceLocation::class.java)
                    stopService(intent)
                    result.success(null)
                }
//                "getStoredLocations" -> {
//                    val sharedPref = getSharedPreferences("location_storage", Context.MODE_PRIVATE)
//                    val data = sharedPref.getString("location_list", "[]")
//                    result.success(data)
//                }
                "getStoredLocations" -> {
                    val prefs = getSharedPreferences("location_storage", Context.MODE_PRIVATE)
                    val data = prefs.getString("location_list", "[]")
                    result.success(data)
                }
                "clearStoredLocations" -> {
                    getSharedPreferences("location_storage", Context.MODE_PRIVATE)
                        .edit().remove("location_list").apply()
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

//    private fun scheduleWorkManagerJob() {
//        val constraints = Constraints.Builder()
//            .setRequiresBatteryNotLow(true)
//            .build()
//
//        val workRequest = PeriodicWorkRequestBuilder<LocationCheckWorker>(15, java.util.concurrent.TimeUnit.MINUTES)
//            .setConstraints(constraints)
//            .build()
//
//        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
//            "LocationChecker",
//            ExistingPeriodicWorkPolicy.KEEP,
//            workRequest
//        )
//    }

//    override fun sendBroadcast(intent: Intent?) {
//        val intent = Intent("android.intent.action.RESTART_LOCATION_SERVICE")
//
//        super.sendBroadcast(intent)
//    }
}
