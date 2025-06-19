//package com.example.location_tracker
//
//import android.app.ActivityManager
//import android.content.Context
//import android.content.Intent
//import android.os.Build
//import android.util.Log
//import androidx.work.Worker
//import androidx.work.WorkerParameters
//
//class LocationCheckWorker(appContext: Context, workerParams: WorkerParameters) :
//    Worker(appContext, workerParams) {
//
//    override fun doWork(): Result {
//        Log.d("LocationCheckWorker", "Running periodic location check")
//
//        if (!isServiceRunning(ServiceLocation::class.java)) {
//            Log.d("LocationCheckWorker", "ServiceLocation not running. Restarting...")
//            val serviceIntent = Intent(applicationContext, ServiceLocation::class.java)
//            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//                applicationContext.startForegroundService(serviceIntent)
//            } else {
//                applicationContext.startService(serviceIntent)
//            }
//        } else {
//            Log.d("LocationCheckWorker", "ServiceLocation is already running.")
//        }
//
//        return Result.success()
//    }
//
//    private fun isServiceRunning(serviceClass: Class<*>): Boolean {
//        val manager = applicationContext.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
//        for (service in manager.getRunningServices(Int.MAX_VALUE)) {
//            if (serviceClass.name == service.service.className) {
//                return true
//            }
//        }
//        return false
//    }
//}
