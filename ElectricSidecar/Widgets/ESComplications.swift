import Foundation
import SwiftUI

var store: ModelStore!

@main
struct ESComplications: WidgetBundle {
  @AppStorage("email", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var email: String = ""
  @AppStorage("password", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var password: String = ""

  init() {
    store = ModelStore(username: email, password: password)
  }

  @WidgetBundleBuilder
  var body: some Widget {
    VehicleChargeWidget()
    VehicleRangeWidget()
  }
}
