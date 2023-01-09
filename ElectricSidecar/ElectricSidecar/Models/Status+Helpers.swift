import Foundation
import PorscheConnect

extension Status {
  /// Returns a human-readable representation of the vehicle's locked state.
  var isLocked: Bool? {
    switch overallLockStatus {
    case "CLOSED_UNLOCKED":
      return false
    case "CLOSED_LOCKED":
      return true
    default:
      return nil
    }
  }

  /// Returns a human-readable representation of the open/closed state of the vehicle's doors.
  var isClosed: Bool? {
    switch overallLockStatus {
    case "CLOSED_UNLOCKED", "CLOSED_LOCKED":
      return true
    default:
      return nil
    }
  }
}
