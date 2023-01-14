import WidgetKit
import SwiftUI

struct VehicleStatusWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "ESComplications.VehicleStatus",
      provider: VehicleStatusTimelineProvider()
    ) { entry in
      VehicleStatusTimelineProvider.EntryView(entry: entry)
    }
    .configurationDisplayName("Door status")
    .description("Show the locked and closed status of the doors")
    .supportedFamilies([.accessoryCircular])
  }
}
