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
  let entry: ChargeRemainingTimelineProvider.Entry

  var body: some View {
    GaugeComplicationView(batteryLevel: entry.chargeRemaining, isCharging: entry.isCharging)
  }
}
