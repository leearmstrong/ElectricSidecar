import WidgetKit
import SwiftUI

struct VehicleRangeWidget: Widget {
  var body: some WidgetConfiguration {
    StaticConfiguration(
      kind: "ESComplications.VehicleRange",
      provider: VehicleRangeTimelineProvider()
    ) { entry in
      WidgetView(entry: entry)
    }
    .configurationDisplayName("Range")
    .description("Show the remaining range on your vehicle")
    .supportedFamilies([.accessoryCircular])
  }
}

private struct WidgetView : View {
  @Environment(\.widgetFamily) var family
  @Environment(\.widgetRenderingMode) var widgetRenderingMode

  let entry: VehicleRangeTimelineProvider.Entry

  var body: some View {
    ZStack {
      RadialProgressView(scale: 1, color: batteryColor.opacity(0.2), lineWidth: 4)
      if let chargeRemaining = entry.chargeRemaining {
        RadialProgressView(scale: chargeRemaining * 0.01, color: batteryColor, lineWidth: 5)
      }
      if let rangeRemaining = entry.rangeRemaining {
        VStack(spacing: 0) {
          Text(String(format: "%.0f", rangeRemaining))
            .font(.system(size: WKInterfaceDevice.current().screenBounds.width < 195 ? 18 : 20))
            .bold()
          Text(Locale.current.measurementSystem == .metric ? "km" : "mi")
            .font(.system(size: WKInterfaceDevice.current().screenBounds.width < 195 ? 12 : 14))
            .padding(.top, -2)
            .padding(.bottom, -14)
        }
      }
    }
    .padding(2.5)
  }

  var batteryColor: Color {
    guard let chargeRemaining = entry.chargeRemaining else {
      return .gray
    }
    if chargeRemaining >= 80 {
      return .green
    } else if chargeRemaining >= 50 {
      return .yellow
    } else if chargeRemaining > 20 {
      return .orange
    } else {
      return .red
    }
  }

}

struct VehicleRangeWidget_Previews: PreviewProvider {
  static var previews: some View {
    WidgetView(entry: VehicleRangeTimelineProvider.Entry(
      date: Date(),
      chargeRemaining: 80,
      rangeRemaining: 120
    ))
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("45mm")
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
    WidgetView(entry: VehicleRangeTimelineProvider.Entry(
      date: Date(),
      chargeRemaining: 80,
      rangeRemaining: 120
    ))
    .previewDevice("Apple Watch Series 8 (41mm)")
    .previewDisplayName("41mm")
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
