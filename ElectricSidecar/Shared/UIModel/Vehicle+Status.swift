import Foundation

extension UIModel.Vehicle {
  struct Status {
    var isLocked: Bool?
    var isClosed: Bool?
    let batteryLevel: Double
    let batteryLevelFormatted: String
    let electricalRange: String?
    let mileage: String
  }
}
