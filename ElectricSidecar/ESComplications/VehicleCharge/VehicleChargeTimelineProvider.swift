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
      do {
        let vehicleList = try await store.vehicleList()

        // TODO: Let the user pick this somehow?
        let firstVehicle = vehicleList[0]

        let emobility = try await store.emobility(for: firstVehicle.vin)

        storage.lastKnownCharge = emobility.batteryChargeStatus.stateOfChargeInPercentage
        storage.lastKnownChargingState = emobility.isCharging
      } catch {
        logger.error("Failed to update complication with error: \(error.localizedDescription)")
      }

      // Always provide a timeline, even if the update request failed.
      let timeline = Timeline(entries: [Entry(
        date: Date(),
        chargeRemaining: storage.lastKnownCharge,
        isCharging: storage.lastKnownChargingState
      )], policy: .after(.now.addingTimeInterval(60 * 30)))
      completion(timeline)
    }
  }
}

struct ChargeRemainingTimelineEntry: TimelineEntry {
  let date: Date
  let chargeRemaining: Double?
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
        isCharging: entry.isCharging == true,
        lineWidth: 4
      )
      .padding(2)
    case .accessoryCorner:
      if let chargeRemaining = entry.chargeRemaining {
        HStack(spacing: 0) {
          Image(entry.isCharging == true ? "taycan.charge" : "taycan")
            .font(.system(size: WKInterfaceDevice.current().screenBounds.width < 195 ? 23 : 26))
            .fontWeight(.regular)
        }
        .widgetLabel {
          Gauge(value: chargeRemaining, in: 0...100.0) {
            Text("")
          } currentValueLabel: {
            Text("")
          } minimumValueLabel: {
            Text("")
          } maximumValueLabel: {
            Text(chargeRemaining < 100 ? Self.formatted(chargeRemaining: chargeRemaining) : "100")
              .foregroundColor(batteryColor)
          }
          .tint(batteryColor)
          .gaugeStyle(LinearGaugeStyle(tint: Gradient(colors: [.red, .orange, .yellow, .green])))
        }
      } else {
        HStack(spacing: 0) {
          Image(entry.isCharging == true ? "taycan.charge" : "taycan")
            .font(.system(size: WKInterfaceDevice.current().screenBounds.width < 195 ? 23 : 26))
            .fontWeight(.regular)
        }
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
        if let chargeRemaining = entry.chargeRemaining {
          Text(Self.formatted(chargeRemaining: chargeRemaining))
        }
      }
    default:
      Text("Unsupported")
    }
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

  static func formatted(chargeRemaining: Double) -> String {
    return String(format: "%.0f%%", chargeRemaining)
  }
}

struct VehicleChargeWidget_Previews: PreviewProvider {
  static var previews: some View {
    VehicleChargeEntryView(entry: ChargeRemainingTimelineEntry(
      date: Date(),
      chargeRemaining: 100,
      isCharging: true
    ))
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
