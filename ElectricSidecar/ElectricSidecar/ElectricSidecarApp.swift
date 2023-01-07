import SwiftUI

extension URLCache {
  static let imageCache = URLCache(memoryCapacity: 20*1024*1024, diskCapacity: 128*1024*1024)
}

@main
struct ElectricSidecar: App {
  @State var email: String = ""
  @State var password: String = ""

  enum AuthState {
    case loggedOut(error: Error?)
    case authenticated
  }
  @State var authState: AuthState

  init() {
    if let userAuth = AuthStore.userAuth(), !userAuth.username.isEmpty && !userAuth.password.isEmpty {
      self.email = userAuth.username
      self.password = userAuth.password
      authState = .authenticated
    } else {
      self.email = ""
      self.password = ""
      authState = .loggedOut(error: nil)
    }
  }

  var body: some Scene {
    WindowGroup {
      switch authState {
      case .authenticated:
        VehicleListView(store: ModelStore(username: email, password: password)) { error in
          authState = .loggedOut(error: error)
        }
      case .loggedOut(let error):
        ScrollView {
          VStack {
            if let error = error {
              Text(error.localizedDescription)
            }
            LoginView(email: $email, password: $password) {
              guard !email.isEmpty && !password.isEmpty else {
                return
              }
              AuthStore.store(username: email, password: password)
              authState = .authenticated
            }
          }
        }
      }
    }
  }
}
