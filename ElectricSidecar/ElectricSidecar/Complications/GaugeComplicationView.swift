import Foundation
import SwiftUI

struct GaugeComplicationView: View {
  @Binding var batteryLevel: Double

  var body: some View {
    Gauge(value: batteryLevel, in: 0...100.0) {
      Text("ºF")
    } currentValueLabel: {
      Image(systemName: "bolt.car")
        .font(.system(.title3))
        .padding(.top, -4)
    } minimumValueLabel: {
      Text("")
    } maximumValueLabel: {
      Text(String(format: "%.0f", batteryLevel)) + Text("%").font(.system(.footnote))
    }
    .gaugeStyle(
      CircularGaugeStyle(tint:
                          Gradient(colors: [.red, .orange, .yellow, .green])))
  }
}
