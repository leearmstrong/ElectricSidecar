import Foundation
import SwiftUI

final class AuthModel {
  @AppStorage("email", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var email: String = ""
  @AppStorage("password", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var password: String = ""

  var store: ModelStore? {
    if email.isEmpty || password.isEmpty {
      return nil
    }
    if let store = _store {
      return store
    }
    _store = ModelStore(username: email, password: password)
    return _store
  }
  private var _store: ModelStore?
}

let AUTH_MODEL = AuthModel()
