import Foundation
import PorscheConnect

extension Doors.DoorStatus {
  var uiModel: UIModel.Vehicle.Doors.Status {
    return .init(isLocked: self == .closedAndLocked, isOpen: self == .openAndUnlocked)
  }
}

extension UIModel.Vehicle {
  struct Doors {
    struct Status {
      var isLocked: Bool
      var isOpen: Bool
    }
    let frontLeft: Status
    let frontRight: Status
    let backLeft: Status
    let backRight: Status
    let frontTrunk: Status
    let backTrunk: Status
    let overallLockStatus: Status
  }
}
