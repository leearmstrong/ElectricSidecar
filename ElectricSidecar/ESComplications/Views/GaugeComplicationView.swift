import Foundation
import SwiftUI
import WidgetKit

struct GaugeComplicationView: View {
  var batteryLevel: Double
  var isCharging: Bool?

  @Environment(\.widgetFamily) var family

  var body: some View {
    switch family {
    case .accessoryCircular:
      Gauge(value: batteryLevel, in: 0...100.0) {
        Text("Charge remaining")
      } currentValueLabel: {
        Image(systemName: "bolt.car")
          .symbolRenderingMode(.palette)
          .foregroundStyle(isCharging == true ? .white : .clear, .white)
          .padding(.top, -4)
      } minimumValueLabel: {
        Text("")
      } maximumValueLabel: {
        Text(Self.formatted(chargeRemaining: batteryLevel * 0.01))
      }
      .gaugeStyle(CircularGaugeStyle(tint: Gradient(colors: [.red, .orange, .yellow, .green])))
    case .accessoryCorner:
      HStack(spacing: 0) {
        Image(systemName: "bolt.car")
          .symbolRenderingMode(.palette)
          .foregroundStyle(.clear, .white)
          .font(.title.bold())
        if isCharging == true {
          Text(Image(systemName: "bolt.fill"))
            .font(.title.bold())
        }
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
    GaugeComplicationView(batteryLevel: 100)
      .previewContext(WidgetPreviewContext(family: .accessoryCircular))
      .previewDisplayName("Circular")
    GaugeComplicationView(batteryLevel: 20, isCharging: true)
      .previewContext(WidgetPreviewContext(family: .accessoryCorner))
      .previewDisplayName("Corner")
  }
}
