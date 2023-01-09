import Foundation
import PorscheConnect

extension Emobility {
  /// Returns a Boolean representation of the vehicle's charging state, if known.
  var isCharging: Bool? {
    switch batteryChargeStatus.chargingState {
    case "CHARGING":
      return true
    default:
      return nil
    }
  }
}
