import Foundation

extension UIModel.Vehicle {
  struct Status {
    let isLocked: Bool?
    let isClosed: Bool?
    let batteryLevel: String
    let electricalRange: String?
    let mileage: String
  }
}
