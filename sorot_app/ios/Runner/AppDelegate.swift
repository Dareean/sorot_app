import UIKit
import GoogleMaps

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GMSServices.provideAPIKey("AIzaSyBJV9vMauhjD32fnlqVq-EtYwCPp-aDcr4")
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}