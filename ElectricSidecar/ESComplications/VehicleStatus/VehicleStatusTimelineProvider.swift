import Foundation
import SwiftUI
import WidgetKit

struct VehicleStatusTimelineProvider: TimelineProvider {
  private final class Storage {
    var lastEntry: Entry?
  }

  struct Entry: TimelineEntry {
    let date: Date
    let isLocked: Bool?
    let isClosed: Bool?
  }

  struct EntryView: View {
    let entry: Entry

    var body: some View {
      DoorStatusView(isLocked: entry.isLocked, isClosed: entry.isClosed)
    }
  }

  private let storage = Storage()

  func placeholder(in context: Context) -> Entry {
    Entry(
      date: Date(),
      isLocked: storage.lastEntry?.isLocked,
      isClosed: storage.lastEntry?.isClosed
    )
  }

  func getSnapshot(in context: Context, completion: @escaping (Entry) -> ()) {
    if context.isPreview {
      completion(Entry(
        date: Date(),
        isLocked: storage.lastEntry?.isLocked,
        isClosed: storage.lastEntry?.isClosed
      ))
    } else {
      completion(Entry(date: Date(), isLocked: true, isClosed: true))
    }
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
    Task {
      var entries: [Entry] = []

      let vehicleList = try await store.vehicleList()

      // TODO: Let the user pick this somehow?
      let firstVehicle = vehicleList[0]

      let status = try await store.status(for: firstVehicle.vin)

      let entry = Entry(
        date: Date(),
        isLocked: status.isLocked,
        isClosed: status.isClosed
      )
      entries.append(entry)
      storage.lastEntry = entry

      let timeline = Timeline(entries: entries, policy: .atEnd)
      completion(timeline)
    }
  }
}

struct VehicleStatusWidget_Previews: PreviewProvider {
  static var previews: some View {
    VehicleStatusTimelineProvider.EntryView(entry: VehicleStatusTimelineProvider.Entry(
      date: Date(),
      isLocked: false,
      isClosed: true
    ))
    .previewContext(WidgetPreviewContext(family: .accessoryCircular))
  }
}
