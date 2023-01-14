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
    personalizedPhoto: Vehicle.VehiclePicture? = nil,
    statusPublisher: AnyPublisher<VehicleModel.VehicleStatus, Error>
  ) {
    self.vin = vin
    self.licensePlate = licensePlate
    self.modelDescription = modelDescription
    self.modelYear = modelYear
    self.color = color
    self.personalizedPhoto = personalizedPhoto
    self.statusPublisher = statusPublisher
  }

  var id: String { vin }

  let vin: String
  let licensePlate: String?
  let modelDescription: String
  let modelYear: String
  let color: Color?
  let personalizedPhoto: Vehicle.VehiclePicture?

  struct VehicleStatus {
    let isLocked: Bool?
    let isClosed: Bool?
    init(status: Status) {
      self.isLocked = status.isLocked
      self.isClosed = status.isClosed
      self.error = nil
    }

    let error: Error?
    init(error: Error) {
      self.isLocked = nil
      self.isClosed = nil
      self.error = error
    }
  }
  let statusPublisher: AnyPublisher<VehicleStatus, Error>
}
