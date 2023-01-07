import Foundation
import SwiftUI
import WidgetKit

struct GaugeComplicationView: View {
  var batteryLevel: Double

  var body: some View {
    Gauge(value: batteryLevel, in: 0...100.0) {
      Text("Charge remaining")
    } currentValueLabel: {
      Image(systemName: "bolt.car")
        .padding(.top, -4)
    } minimumValueLabel: {
      Text("")
    } maximumValueLabel: {
      Text(Self.formatted(chargeRemaining: batteryLevel * 0.01))
    }
    .gaugeStyle(CircularGaugeStyle(tint: Gradient(colors: [.red, .orange, .yellow, .green])))
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
  }
}
