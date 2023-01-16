import Foundation
import SwiftUI
import WidgetKit

struct GaugeComplicationView: View {
  var batteryLevel: Double
  var isCharging: Bool?

  @Environment(\.widgetFamily) var family
  @Environment(\.widgetRenderingMode) var widgetRenderingMode

  var body: some View {
    switch family {
    case .accessoryCircular:
      Gauge(value: batteryLevel, in: 0...100.0) {
        Text("Charge remaining")
      } currentValueLabel: {
        Image(isCharging == true ? "taycan.charge" : "taycan")
          .fontWeight(.regular)
          .padding(.top, -4)
      } minimumValueLabel: {
        Text("")
      } maximumValueLabel: {
        Text(Self.formatted(chargeRemaining: batteryLevel * 0.01))
      }
      .gaugeStyle(CircularGaugeStyle(tint: Gradient(colors: [.red, .orange, .yellow, .green])))
    case .accessoryCorner:
      HStack(spacing: 0) {
        Image(isCharging == true ? "taycan.charge" : "taycan")
          .font(.system(size: 26))
          .fontWeight(.regular)
          .foregroundColor(batteryColor)
      }
      .widgetLabel {
        Gauge(value: batteryLevel, in: 0...100.0) {
          Text("")
        } currentValueLabel: {
          Text("")
        } minimumValueLabel: {
          Text("")
        } maximumValueLabel: {
          Text(Self.formatted(chargeRemaining: batteryLevel * 0.01))
            .foregroundColor(batteryColor)
        }
        .tint(batteryColor)
        .gaugeStyle(LinearGaugeStyle(tint: Gradient(colors: [.red, .orange, .yellow, .green])))
      }
    case .accessoryInline:
      // Note: inline accessories only support one Text and/or Image element. Any additional
      // elements will be ignored.
      HStack {
        if widgetRenderingMode == .fullColor {
          Image(systemName: "bolt.car")
            .symbolRenderingMode(.palette)
            .foregroundStyle(isCharging == true ? .white : .clear, .white)
        } else {
          // Non-full-color rendering modes don't support palette rendering, so we need to use
          // an alternate glyph instead.
          Image(systemName: isCharging == true ? "bolt.car" : "car")
        }
        Text(Self.formatted(chargeRemaining: batteryLevel * 0.01))
      }
    default:
      Text("Unsupported")
    }
  }

  var batteryColor: Color {
    if batteryLevel >= 80 {
      return .green
    } else if batteryLevel >= 50 {
      return .yellow
    } else if batteryLevel > 20 {
      return .orange
    } else {
      return .red
    }
  }

  static func formatted(chargeRemaining: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 0
    return formatter.string(from: chargeRemaining as NSNumber)!
  }
}

struct GaugeComplicationView_Previews: PreviewProvider {
  static var previews: some View {
    GaugeComplicationView(batteryLevel: 100, isCharging: true)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
      .previewDisplayName("Circular")
    GaugeComplicationView(batteryLevel: 20, isCharging: true)
      .previewContext(WidgetPreviewContext(family: .accessoryCorner))
      .previewDisplayName("Corner")
    GaugeComplicationView(batteryLevel: 20, isCharging: false)
      .previewContext(WidgetPreviewContext(family: .accessoryInline))
      .previewDisplayName("Inline")
    GaugeComplicationView(batteryLevel: 20, isCharging: true)
      .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
      .previewDisplayName("Rectangular")
  }
}
