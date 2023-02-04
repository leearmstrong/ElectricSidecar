import UIKit
import WatchConnectivity

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  private lazy var watchConnectivityDelegate: WCSessionDelegate = {
    return WatchConnectivityObserver(email: "", password: "")
  }()

  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    WCSession.default.delegate = watchConnectivityDelegate
    WCSession.default.activate()

    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
}
