import Foundation
import OSLog
import SwiftUI

extension OSLogEntry: Identifiable {
  var logLevel: OSLogEntryLog.Level? {
    if let log = self as? OSLogEntryLog {
      return log.level
    }
    return nil
  }
}

extension OSLogEntryLog.Level {
  var asString: String {
    switch self {
    case .error: return "Error"
    case .info: return "Info"
    case .debug: return "Debug"
    case .fault: return "Fault"
    case .notice: return "Notice"
    case .undefined: return "Undefine"
    @unknown default:
      return "Unknown"
    }
  }
}

struct LogsView: View {
  @State var entries: [OSLogEntry] = []

  var body: some View {
    List(entries.reversed()) { entry in
      VStack(alignment: .leading) {
        Text(entry.date.ISO8601Format())
          .font(.footnote)
          .foregroundColor(.gray)
        Text(entry.composedMessage)
          .font(.body)
          .foregroundColor(entry.logLevel == .error ? Color.red : nil)
        if let log = entry as? OSLogEntryLog {
          Text(log.level.asString)
            .font(.footnote)
            .foregroundColor(.gray)
        }
      }
    }
    .onAppear {
      refresh()
    }
  }

  private func refresh() {
    let startTime = Date(timeIntervalSinceNow: -60 * 60)
    let logStore = try! OSLogStore(scope: .currentProcessIdentifier)
    let predicate = NSPredicate(format: "subsystem == %@", argumentArray: [LOGGER_SUBSYSTEM])
    let position = logStore.position(date: startTime)
    entries = Array(try! logStore.getEntries(at: position, matching: predicate))
  }
}
