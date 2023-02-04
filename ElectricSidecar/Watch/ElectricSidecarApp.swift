import SwiftUI
import WatchConnectivity

@main
struct ElectricSidecar: App {
  @AppStorage("email", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var email: String = ""
  @AppStorage("password", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var password: String = ""

  enum AuthState {
    case launching
    case loggedOut(error: Error?)
    case authenticated(store: ModelStore)
  }
  @State var authState: AuthState = .launching

  private let watchConnectivityDelegate: WatchConnectivityObserver

  init() {
    watchConnectivityDelegate = WatchConnectivityObserver()
    watchConnectivityDelegate.email = email
    watchConnectivityDelegate.password = password
    WCSession.default.delegate = watchConnectivityDelegate
    WCSession.default.activate()
  }

  var body: some Scene {
    WindowGroup {
      switch authState {
      case .launching:
        ProgressView()
          .task {
            if email.isEmpty || password.isEmpty {
              authState = .loggedOut(error: nil)
            } else {
              let store = ModelStore(username: email, password: password)
              Task {
                try await store.load()
              }
              authState = .authenticated(store: store)
            }
          }
      case .authenticated(let store):
        GarageView(store: store) { error in
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
              watchConnectivityDelegate.email = email
              watchConnectivityDelegate.password = password
              let store = ModelStore(username: email, password: password)
              Task {
                try await store.load()
              }
              authState = .authenticated(store: store)
            }
          }
        }
      }
    }
  }
}
