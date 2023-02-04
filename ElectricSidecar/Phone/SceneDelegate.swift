import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  @AppStorage("email", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var email: String = ""
  @AppStorage("password", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var password: String = ""

  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    if email.isEmpty || password.isEmpty {
      let loginViewController = LoginViewController(email: email, password: password)
      loginViewController.delegate = self
      let navigation = UINavigationController(rootViewController: loginViewController)
      window.rootViewController = navigation
    } else {
      login()
    }

    window.makeKeyAndVisible()
  }
}

extension SceneDelegate: LoginViewControllerDelegate {
  func login() {
    let store = ModelStore(username: email, password: password)
    Task {
      try await store.load()
    }
    let garageView = GarageView(store: store) { error in
      print("Logged out due to error: \(error)")
    }
    let hostingController = UIHostingController(rootView: garageView)
    window?.rootViewController = hostingController
  }

  func loginViewController(_ loginViewController: LoginViewController, didLoginWithEmail email: String, password: String) {
    self.email = email
    self.password = password

    login()
  }
}
