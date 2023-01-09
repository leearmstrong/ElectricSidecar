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
      picture.view == "personalized" && picture.size == 2
    })
  }
  enum Camera: String {
    case front = "extcam01"
    case side = "extcam02"
    case rear = "extcam03"
    case topAngled = "extcam04"
    case overhead = "extcam05"
    case dashboard = "intcam01"
    case cabin = "intcam02"
  }
  func externalCamera(_ camera: Camera, size: Int) -> VehiclePicture? {
    return pictures?.first(where: { picture in
      picture.view == camera.rawValue && picture.size == size
    })
  }
}
