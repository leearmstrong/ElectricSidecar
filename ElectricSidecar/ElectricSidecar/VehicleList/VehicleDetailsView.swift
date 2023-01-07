import CachedAsyncImage
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleDetailsView: View {
  @Binding var vehicle: Vehicle
  var body: some View {
    VStack(alignment: .leading) {
      if let camera = vehicle.personalizedPhoto {
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
              (vehicle.color ?? .gray)
                .aspectRatio(CGSize(width: CGFloat(camera.width), height: CGFloat(camera.height)),
                             contentMode: .fill)
              ProgressView()
            }
          }
        )
      }
      Text("\(vehicle.modelDescription) (\(vehicle.modelYear))")
      Text(vehicle.vin)
    }
  }
}
