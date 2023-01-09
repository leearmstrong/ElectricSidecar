import CachedAsyncImage
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleDetailsView: View {
  var camera: Vehicle.VehiclePicture?
  var vehicleColor: Color?
  var modelDescription: String
  var modelYear: String
  var vin: String

  var body: some View {
    VStack(alignment: .leading) {
      if let camera = camera {
        CachedAsyncImage(
          url: camera.url,
          urlCache: .imageCache,
          content: { image in
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
          },
          placeholder: {
            ZStack {
              (vehicleColor ?? .gray)
                .aspectRatio(CGSize(width: CGFloat(camera.width), height: CGFloat(camera.height)),
                             contentMode: .fill)
              ProgressView()
            }
          }
        )
      }
      Text("\(modelDescription) (\(modelYear))")
      Text(vin)
    }
  }
}

struct VehicleDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    VehicleDetailsView(
      modelDescription: "Taycan",
      modelYear: "2022",
      vin: "ABC123"
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Series 8 45mm")
  }
}
