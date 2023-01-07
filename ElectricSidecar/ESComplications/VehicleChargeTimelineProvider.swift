import Foundation
import SwiftUI
import WidgetKit

private final class Storage {
  var lastKnownCharge: Double?
}

struct ChargeRemainingTimelineProvider: TimelineProvider {
  typealias Entry = ChargeRemainingTimelineEntry

  let store: ModelStore
  private let storage = Storage()

  func placeholder(in context: Context) -> ChargeRemainingTimelineEntry {
    Entry(date: Date(), chargeRemaining: storage.lastKnownCharge ?? 100)
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
    if context.isPreview {
      let entry = Entry(date: Date(), chargeRemaining: storage.lastKnownCharge ?? 100)
      completion(entry)
    } else {
      let entry = Entry(date: Date(), chargeRemaining: 100)
      completion(entry)
    }
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task {
      var entries: [Entry] = []

      let vehicleList = try await store.vehicleList()

      // TODO: Let the user pick this somehow?
      let firstVehicle = vehicleList[0]

      let status = try await store.status(for: firstVehicle)

      storage.lastKnownCharge = status.batteryLevel.value

      let entry = Entry(date: Date(), chargeRemaining: status.batteryLevel.value)
      entries.append(entry)

      let timeline = Timeline(entries: entries, policy: .atEnd)
      completion(timeline)
    }
  }
}

struct ChargeRemainingTimelineEntry: TimelineEntry {
  let date: Date
  let chargeRemaining: Double
}

struct VehicleChargeEntryView : View {
  let entry: ChargeRemainingTimelineProvider.Entry

  var body: some View {
    GaugeComplicationView(batteryLevel: entry.chargeRemaining)
  }
}
