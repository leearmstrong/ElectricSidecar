import SwiftUI

@main
struct ElectricSidecar: App {
  @State var username: String = ""
  @State var password: String = ""
  var body: some Scene {
    WindowGroup {
      LoginView(email: $username, password: $password) {
        print("Did log in")
      }
    }
  }
}
