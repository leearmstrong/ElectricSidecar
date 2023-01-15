import WidgetKit
import SwiftUI

struct VehicleChargeWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "ESComplications.VehicleCharge",
      provider: ChargeRemainingTimelineProvider()
    ) { entry in
        VehicleChargeEntryView(entry: entry)
      }
      .configurationDisplayName("Charge")
      .description("Show the remaining charge on your vehicle")
      .supportedFamilies([.accessoryCircular, .accessoryCorner])
  }
}

struct VehicleChargeWidget_Previews: PreviewProvider {
  static var previews: some View {
    VehicleChargeEntryView(entry: ChargeRemainingTimelineEntry(
      date: Date(),
      chargeRemaining: 100,
      isCharging: false
    ))
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
