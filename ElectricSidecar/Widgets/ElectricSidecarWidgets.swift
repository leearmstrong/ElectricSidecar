import Foundation
import SwiftUI
import WatchConnectivity

final class SingletonModel {
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

let singletonModel = SingletonModel()

@main
struct ElectricSidecarWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    VehicleChargeWidget()
    VehicleRangeWidget()
#if !os(watchOS)
    ChargingLiveActivity()
#endif
  }
}
