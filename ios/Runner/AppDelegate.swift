import UIKit
import Flutter
import GoogleMaps
import UserNotificationsUI
//import FirebaseMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        GMSServices.provideAPIKey("AIzaSyCm_WSlikN2b9oua3JZ6HebiXnsZfvjRIw")
        GeneratedPluginRegistrant.register(with: self)
        UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // This method will be called when app received push notifications in foreground
    override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
    {
        completionHandler([.alert, .badge, .sound])
    }
    
    //    override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    //        Messaging.messaging().apnsToken = deviceToken
    //    }
}
