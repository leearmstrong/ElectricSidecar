import Foundation
import PorscheConnect

extension Vehicle {
  var licensePlate: String? {
    return attributes?.first(where: { attribute in
      attribute.name == "licenseplate"
    })?.value
  }
  var personalizedPhoto: VehiclePicture? {
    return pictures?.first(where: { picture in
      picture.view == .personalized && picture.size == 2
    })
  }
  func externalCamera(_ camera: VehiclePicture.CameraView, size: Int) -> VehiclePicture? {
    return pictures?.first(where: { picture in
      picture.view == camera && picture.size == size
    })
  }
}
