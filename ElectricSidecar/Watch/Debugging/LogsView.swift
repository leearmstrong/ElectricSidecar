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
    entries = Logging.latestEntries()
  }
}
