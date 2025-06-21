//
//  LocationService.swift
//  Runner
//
//  Created by Ishan  Dusane on 20/06/25.
//

import Foundation
import Foundation
import CoreLocation
import Flutter
import GoogleMaps

class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    private var locationManager: CLLocationManager?
    private var methodChannel: FlutterMethodChannel?

    func start(channel: FlutterMethodChannel) {
        methodChannel = channel
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.pausesLocationUpdatesAutomatically = false
        locationManager?.startUpdatingLocation()
        locationManager?.requestAlwaysAuthorization()
    }

    func stop() {
        locationManager?.stopUpdatingLocation()
        locationManager = nil
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        let latitude = latest.coordinate.latitude
        let longitude = latest.coordinate.longitude
        let timestamp = Date().timeIntervalSince1970 * 1000

        let dict: [String: Any] = ["latitude": latitude, "longitude": longitude, "timestamp": timestamp]
        var stored = UserDefaults.standard.array(forKey: "location_list") as? [[String: Any]] ?? []
        stored.append(dict)
        UserDefaults.standard.set(stored, forKey: "location_list")

//        methodChannel?.invokeMethod("sendLocation", arguments: dict)
    }
}
