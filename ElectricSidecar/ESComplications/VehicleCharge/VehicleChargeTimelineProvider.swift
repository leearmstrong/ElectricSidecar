import Foundation
import SwiftUI
import WidgetKit

private final class Storage {
  var lastKnownCharge: Double?
  var lastKnownChargingState: Bool?
}

struct ChargeRemainingTimelineProvider: TimelineProvider {
  typealias Entry = ChargeRemainingTimelineEntry

  private let storage = Storage()

  func placeholder(in context: Context) -> ChargeRemainingTimelineEntry {
    Entry(
      date: Date(),
      chargeRemaining: storage.lastKnownCharge ?? 100,
      isCharging: storage.lastKnownChargingState
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
    if context.isPreview {
      let entry = Entry(
        date: Date(),
        chargeRemaining: storage.lastKnownCharge ?? 100,
        isCharging: storage.lastKnownChargingState
      )
      completion(entry)
    } else {
      let entry = Entry(date: Date(), chargeRemaining: 100, isCharging: false)
      completion(entry)
    }
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task {
      var entries: [Entry] = []

      let vehicleList = try await store.vehicleList()

      // TODO: Let the user pick this somehow?
      let firstVehicle = vehicleList[0]

      let emobility = try await store.emobility(for: firstVehicle.vin)

      storage.lastKnownCharge = emobility.batteryChargeStatus.stateOfChargeInPercentage
      storage.lastKnownChargingState = emobility.isCharging

      let entry = Entry(
        date: Date(),
        chargeRemaining: emobility.batteryChargeStatus.stateOfChargeInPercentage,
        isCharging: emobility.isCharging
      )
      entries.append(entry)

      let timeline = Timeline(entries: entries, policy: .atEnd)
      completion(timeline)
    }
  }
}

struct ChargeRemainingTimelineEntry: TimelineEntry {
  let date: Date
  let chargeRemaining: Double
  let isCharging: Bool?
}

struct VehicleChargeEntryView : View {
  @Environment(\.widgetFamily) var family
  @Environment(\.widgetRenderingMode) var widgetRenderingMode

  let entry: ChargeRemainingTimelineProvider.Entry

  var body: some View {

    switch family {
    case .accessoryCircular:
      ChargeView(
        batteryLevel: entry.chargeRemaining,
        isCharging: entry.isCharging,
        lineWidth: 4
      )
      .padding(2)
    case .accessoryCorner:
      HStack(spacing: 0) {
        Image(entry.isCharging == true ? "taycan.charge" : "taycan")
          .font(.system(size: 26))
          .fontWeight(.regular)
      }
      .widgetLabel {
        Gauge(value: entry.chargeRemaining, in: 0...100.0) {
          Text("")
        } currentValueLabel: {
          Text("")
        } minimumValueLabel: {
          Text("")
        } maximumValueLabel: {
          Text(Self.formatted(chargeRemaining: entry.chargeRemaining * 0.01))
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
            .foregroundStyle(entry.isCharging == true ? .white : .clear, .white)
        } else {
          // Non-full-color rendering modes don't support palette rendering, so we need to use
          // an alternate glyph instead.
          Image(systemName: entry.isCharging == true ? "bolt.car" : "car")
        }
        Text(Self.formatted(chargeRemaining: entry.chargeRemaining * 0.01))
      }
    default:
      Text("Unsupported")
    }
  }

  var batteryColor: Color {
    if entry.chargeRemaining >= 80 {
      return .green
    } else if entry.chargeRemaining >= 50 {
      return .yellow
    } else if entry.chargeRemaining > 20 {
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

struct VehicleChargeWidget_Previews: PreviewProvider {
  static var previews: some View {
    VehicleChargeEntryView(entry: ChargeRemainingTimelineEntry(
      date: Date(),
      chargeRemaining: 20,
      isCharging: true
    ))
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
