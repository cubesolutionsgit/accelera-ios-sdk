import UIKit
import Accelera

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        Accelera.shared.configure(config: AcceleraConfig(
            systemToken: "",
            url: "https://g1-dev.accelera.ai"
        ))
                
        UNUserNotificationCenter.current().delegate = self
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any]) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            Log.shared.info("Push notification received: \(data)")
        }
        
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        Accelera.shared.handlePushNotificationOpened(userInfo: notification.request.content.userInfo)
        return [[.list, .banner, .sound]]
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse) async {
        Accelera.shared.handlePushNotificationOpened(userInfo: response.notification.request.content.userInfo)
    }
}
