import Foundation

extension UIModel.Vehicle {
  struct Status {
    let batteryLevel: Double
    let electricalRange: String?
    let mileage: String
    let doors: UIModel.Vehicle.Doors
  }
}
