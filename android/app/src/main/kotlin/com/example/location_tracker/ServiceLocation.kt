//package com.example.location_tracker
//
//import android.Manifest
//import android.app.*
//import android.content.Context
//import android.content.Intent
//import android.content.pm.PackageManager
//import android.location.Location
//import android.os.Build
//import android.os.IBinder
//import android.os.Looper
//import androidx.core.app.ActivityCompat
//import com.google.android.gms.location.*
//import io.flutter.plugin.common.MethodChannel
//import io.flutter.view.FlutterMain
//import io.flutter.embedding.engine.FlutterEngine
//import io.flutter.embedding.engine.dart.DartExecutor
//import io.flutter.embedding.engine.FlutterEngineCache
//import org.json.JSONArray
//import org.json.JSONObject
//
//class ServiceLocation : Service() {
//    private lateinit var fusedLocationClient: FusedLocationProviderClient
//    private lateinit var locationRequest: LocationRequest
//    private lateinit var locationCallback: LocationCallback
//    private var methodChannel: MethodChannel? = null
//
//    override fun onCreate() {
//        super.onCreate()
//        createNotification()
////        startFlutterEngine()
//        setupMethodChannel()
//        startLocationTracking()
//    }
//
//    private fun createNotification() {
//        val channelId = "location_channel"
//        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            val channel = NotificationChannel(channelId, "Location Service", NotificationManager.IMPORTANCE_LOW)
//            notificationManager.createNotificationChannel(channel)
//        }
//
//        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            Notification.Builder(this, channelId)
//                .setContentTitle("Tracking location")
//                .setSmallIcon(R.mipmap.ic_launcher)
//                .build()
//        } else {
//            TODO("VERSION.SDK_INT < O")
//        }
//
//        startForeground(1, notification)
//    }
//
////    private fun startFlutterEngine() {
////        FlutterMain.startInitialization(this)
////        val engine = FlutterEngine(this)
////        engine.dartExecutor.executeDartEntrypoint(
////            DartExecutor.DartEntrypoint.createDefault()
////        )
////        FlutterEngineCache.getInstance().put("engine_id", engine)
////        methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "background_location_channel")
////    }
//
//    private fun setupMethodChannel() {
//        val engine = FlutterEngineCache.getInstance().get("shared_engine")
//        if (engine != null) {
//            methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "background_location_channel")
//        } else {
//            FlutterMain.startInitialization(this)
//        val engine = FlutterEngine(this)
//        engine.dartExecutor.executeDartEntrypoint(
//            DartExecutor.DartEntrypoint.createDefault()
//        )
//        FlutterEngineCache.getInstance().put("engine_id", engine)
//        methodChannel = MethodChannel(engine.dartExecutor.binaryMessenger, "background_location_channel")
//        }
//    }
//
//
//    private fun startLocationTracking() {
//        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)
//
//        locationRequest = LocationRequest.create().apply {
//            interval = 10000
//            fastestInterval = 5000
//            priority = LocationRequest.PRIORITY_HIGH_ACCURACY
//        }
//
//        locationCallback = object : LocationCallback() {
//            override fun onLocationResult(result: LocationResult) {
//                val location: Location? = result.lastLocation
//                if (location != null) {
//                    sendLocationToFlutter(location)
//                }
//            }
//        }
//
//        if (ActivityCompat.checkSelfPermission(
//                this,
//                Manifest.permission.ACCESS_FINE_LOCATION
//            ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
//                this,
//                Manifest.permission.ACCESS_COARSE_LOCATION
//            ) != PackageManager.PERMISSION_GRANTED
//        ) {
//            // TODO: Consider calling
//            //    ActivityCompat#requestPermissions
//            // here to request the missing permissions, and then overriding
//            //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
//            //                                          int[] grantResults)
//            // to handle the case where the user grants the permission. See the documentation
//            // for ActivityCompat#requestPermissions for more details.
//            return
//        }
//        fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
//    }
//
//    private fun sendLocationToFlutter(location: Location) {
//
//        val sharedPref = getSharedPreferences("location_storage", Context.MODE_PRIVATE)
//        val editor = sharedPref.edit()
//        val stored = sharedPref.getString("location_list", "[]")
//
//        val updatedList = JSONArray(stored).apply {
//            put(JSONObject().apply {
//                put("latitude", location.latitude)
//                put("longitude", location.longitude)
//                put("timestamp", System.currentTimeMillis())
//            })
//        }
//
//        editor.putString("location_list", updatedList.toString())
//        editor.apply()
//
//        val locationMap = mapOf(
//            "latitude" to location.latitude,
//            "longitude" to location.longitude,
//            "timestamp" to System.currentTimeMillis()
//        )
//        methodChannel?.invokeMethod("sendLocation", locationMap)
//    }
//
//    override fun onBind(intent: Intent?): IBinder? = null
//
//    override fun onDestroy() {
//        fusedLocationClient.removeLocationUpdates(locationCallback)
//        val sharedPref = getSharedPreferences("location_storage", Context.MODE_PRIVATE)
//        sharedPref.edit().remove("location_list").apply()
//
//        super.onDestroy()
//    }
//
//    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
//        return START_STICKY
//    }
//}

package com.example.location_tracker

import android.Manifest
import android.app.*
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.Location
import android.os.Build
import android.os.IBinder
import android.os.Looper
import android.util.Log
import androidx.core.app.ActivityCompat
import com.google.android.gms.location.*
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject

class ServiceLocation : Service() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback
    private var methodChannel: MethodChannel? = null

    override fun onCreate() {
        super.onCreate()
        createNotification()
        setupLocationTracking()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private fun createNotification() {
        val channelId = "location_channel"
        val manager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(channelId, "Location Service", NotificationManager.IMPORTANCE_LOW)
            manager.createNotificationChannel(channel)
        }

        val notification = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("Tracking location")
                .setSmallIcon(R.mipmap.ic_launcher)
                .build()
        } else {
            TODO("VERSION.SDK_INT < O")
        }

        startForeground(1, notification)
    }

    private fun setupLocationTracking() {
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        val locationRequest = LocationRequest.create().apply {
            interval = 10000
            fastestInterval = 5000
            priority = Priority.PRIORITY_HIGH_ACCURACY
        }

        locationCallback = object : LocationCallback() {
            override fun onLocationResult(result: LocationResult) {
                val location = result.lastLocation
                if (location != null) {
                    storeLocationToPrefs(location)
                }
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_FINE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED && ActivityCompat.checkSelfPermission(
                    this,
                    Manifest.permission.ACCESS_COARSE_LOCATION
                ) != PackageManager.PERMISSION_GRANTED
            ) {
                // TODO: Consider calling
                //    ActivityCompat#requestPermissions
                // here to request the missing permissions, and then overriding
                //   public void onRequestPermissionsResult(int requestCode, String[] permissions,
                //                                          int[] grantResults)
                // to handle the case where the user grants the permission. See the documentation
                // for ActivityCompat#requestPermissions for more details.
                return
            }
            fusedLocationClient.requestLocationUpdates(locationRequest, locationCallback, Looper.getMainLooper())
        }
    }

    private fun storeLocationToPrefs(location: Location) {
        val prefs = getSharedPreferences("location_storage", Context.MODE_PRIVATE)
        val current = prefs.getString("location_list", "[]")
        val list = JSONArray(current)

        val json = JSONObject().apply {
            put("latitude", location.latitude)
            put("longitude", location.longitude)
            put("timestamp", System.currentTimeMillis())
        }

        list.put(json)
        prefs.edit().putString("location_list", list.toString()).apply()

        Log.d("ServiceLocation", "Stored location to prefs: $json")
    }

    override fun onDestroy() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
        Log.d("ServiceLocation", "Service destroyed and stopped tracking.")
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null
}

