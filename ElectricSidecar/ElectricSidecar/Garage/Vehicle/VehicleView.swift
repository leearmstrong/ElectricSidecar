import CachedAsyncImage
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleView: View {
  let store: ModelStore
  @Binding var vehicle: Vehicle

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        VehicleStatusView(store: store, vehicle: $vehicle)
        VehicleLocationView(store: store, vehicle: $vehicle)
          .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

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

        VehicleDetailsView(
          modelDescription: vehicle.modelDescription,
          modelYear: vehicle.modelYear,
          vin: vehicle.vin
        )
      }
    }
  }
}