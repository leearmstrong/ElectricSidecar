import Foundation
import SwiftUI
import WatchConnectivity

var store: ModelStore!

@main
struct ESComplications: WidgetBundle {
  @AppStorage("email", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var email: String = ""
  @AppStorage("password", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var password: String = ""

  private lazy var watchConnectivityDelegate: WCSessionDelegate = {
    return WatchConnectivityObserver(email: email, password: password)
  }()

  init() {
    WCSession.default.delegate = watchConnectivityDelegate
    WCSession.default.activate()

    store = ModelStore(username: email, password: password)
  }

  @WidgetBundleBuilder
  var body: some Widget {
    VehicleChargeWidget()
    VehicleRangeWidget()
  }
}
