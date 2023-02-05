import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
  var window: UIWindow?

  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = scene as? UIWindowScene else {
      return
    }

    let window = UIWindow(windowScene: windowScene)
    self.window = window

    if AUTH_MODEL.email.isEmpty || AUTH_MODEL.password.isEmpty {
      let loginViewController = LoginViewController(email: AUTH_MODEL.email, password: AUTH_MODEL.password)
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
    guard let store = AUTH_MODEL.store else {
      return
    }
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
    AUTH_MODEL.email = email
    AUTH_MODEL.password = password

    login()
  }
}
