import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleModel: Identifiable {
  public init(
    vin: String,
    licensePlate: String? = nil,
    modelDescription: String,
    modelYear: String,
    color: Color? = nil,
    personalizedPhoto: Vehicle.VehiclePicture? = nil
  ) {
    self.vin = vin
    self.licensePlate = licensePlate
    self.modelDescription = modelDescription
    self.modelYear = modelYear
    self.color = color
    self.personalizedPhoto = personalizedPhoto
  }

  var id: String { vin }

  let vin: String
  let licensePlate: String?
  let modelDescription: String
  let modelYear: String
  let color: Color?
  let personalizedPhoto: Vehicle.VehiclePicture?
}
