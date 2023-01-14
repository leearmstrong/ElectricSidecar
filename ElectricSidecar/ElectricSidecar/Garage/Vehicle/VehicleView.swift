import CachedAsyncImage
import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleView: View {
  let vehicle: VehicleModel
  @State var status: VehicleStatus?
  let statusPublisher: AnyPublisher<VehicleStatus, Error>

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        VehicleStatusView(vehicle: vehicle, status: $status)
//        VehicleLocationView(store: store, vehicle: vehicle)
//          .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
//
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
    .onReceive(statusPublisher
      .receive(on: RunLoop.main)
      .catch({ error in
        // TODO: Handle this as an enum type somehow so that we don't have to create a dummy status.
        return Just(VehicleStatus(error: error))
      })
    ) { status in
      self.status = status
    }
  }
}
