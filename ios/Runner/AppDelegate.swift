import UIKit
import Flutter
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      
      GMSServices.provideAPIKey("AIzaSyChlNAE3dgB20vvNmR3iS0SFETM54hgWlo")
      
      let controller: FlutterViewController = window?.rootViewController as! FlutterViewController
          let methodChannel = FlutterMethodChannel(name: "background_location_channel", binaryMessenger: controller.binaryMessenger)

          methodChannel.setMethodCallHandler { [weak self] (call, result) in
            switch call.method {
            case "startService":
              LocationService.shared.start(channel: methodChannel)
              result(nil)
            case "stopService":
              LocationService.shared.stop()
              result(nil)
            case "getStoredLocations":
              let list = UserDefaults.standard.array(forKey: "location_list") ?? []
              if let jsonData = try? JSONSerialization.data(withJSONObject: list),
                 let jsonString = String(data: jsonData, encoding: .utf8) {
                result(jsonString)
              } else {
                result("[]")
              }
            case "clearStoredLocations":
              UserDefaults.standard.removeObject(forKey: "location_list")
              result(nil)
            default:
              result(FlutterMethodNotImplemented)
            }
          }
      
      GeneratedPluginRegistrant.register(with: self)
//      GeneratedPluginRegistrant.register(withRegistry: <#T##Any!#>: self as? FlutterPluginRegistry)
      
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
