import WidgetKit
import SwiftUI
import Intents

@main
struct ESComplications: Widget {
  @AppStorage("email", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var email: String = ""
  @AppStorage("password", store: UserDefaults(suiteName: APP_GROUP_IDENTIFIER))
  var password: String = ""

  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "ESComplications",
      provider: ChargeRemainingTimelineProvider(store: ModelStore(username: email,
                                                                password: password))) { entry in
        VehicleChargeEntryView(entry: entry)
    }
    .configurationDisplayName("Charge")
    .description("Show the remaining charge on your vehicle")
    .supportedFamilies([.accessoryCircular])
  }
}

struct ESComplications_Previews: PreviewProvider {
  static var previews: some View {
    VehicleChargeEntryView(entry: ChargeRemainingTimelineEntry(
      date: Date(),
      chargeRemaining: 100,
      isCharging: false
    ))
      .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
  }
}
