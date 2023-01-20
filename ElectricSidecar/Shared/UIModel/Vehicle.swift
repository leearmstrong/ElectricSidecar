import Combine
import Foundation
import PorscheConnect
import SwiftUI

// TODO: Make a UIModel representation of this type
typealias Picture = Vehicle.VehiclePicture

extension Picture: Identifiable {
  public var id: String {
    return url.absoluteString
  }
}

extension UIModel {
  struct Vehicle: Identifiable {
    public init(
      vin: String,
      licensePlate: String? = nil,
      modelDescription: String,
      modelYear: String,
      color: Color? = nil,
      personalizedPhoto: Picture? = nil,
      externalPhotos: [Picture]? = nil
    ) {
      self.vin = vin
      self.licensePlate = licensePlate
      self.modelDescription = modelDescription
      self.modelYear = modelYear
      self.color = color
      self.personalizedPhoto = personalizedPhoto
      self.externalPhotos = externalPhotos ?? []
    }

    var id: String { vin }

    let vin: String
    let licensePlate: String?
    let modelDescription: String
    let modelYear: String
    let color: Color?
    let personalizedPhoto: Picture?
    let externalPhotos: [Picture]
  }
}
