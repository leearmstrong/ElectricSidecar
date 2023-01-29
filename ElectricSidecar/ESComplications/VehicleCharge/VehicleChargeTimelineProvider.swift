import Foundation
import SwiftUI
import WidgetKit

private final class Storage {
  var lastKnownCharge: Double?
  var lastKnownChargingState: Bool?
}

struct ChargeRemainingTimelineEntry: TimelineEntry {
  let date: Date
  let chargeRemaining: Double?
  let isCharging: Bool?
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
