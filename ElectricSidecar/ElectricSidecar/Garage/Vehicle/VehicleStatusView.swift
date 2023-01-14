import CachedAsyncImage
import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleStatusView: View {
  init(vehicle: VehicleModel) {
    self.vehicle = vehicle
  }

  let vehicle: VehicleModel
  private let statusFormatter = StatusFormatter()
  private var cancellables = Set<AnyCancellable>()

  @State var status: VehicleModel.VehicleStatus?

  var body: some View {
    ZStack {
      VStack(alignment: .leading) {
        HStack {
          Text(vehicle.licensePlate ?? "\(vehicle.modelDescription) (\(vehicle.modelYear))")
            .font(.title2)
          Spacer()
          if let isLocked = status?.isLocked {
            Image(systemName: isLocked ? "lock" : "lock.open")
              .font(.body)
          }
          if let isClosed = status?.isClosed {
            Image(systemName: isClosed ? "door.left.hand.closed" : "door.left.hand.open")
          }
        }
//        HStack(spacing: 0) {
//          if emobility.isCharging == true {
//            Text(Image(systemName: "bolt.fill"))
//          }
//          Text(statusFormatter.batteryLevel(from: status))
//          if let remainingRange = statusFormatter.electricalRange(from: status) {
//            Text(", \(remainingRange)")
//          }
//          Spacer()
//        }
//
//        if let camera = vehicle.externalCamera(.front, size: 2) {
//          CachedAsyncImage(
//            url: camera.url,
//            urlCache: .imageCache,
//            content: { image in
//              image
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//            },
//            placeholder: {
//              ZStack {
//                (vehicle.color ?? .gray)
//                  .aspectRatio(CGSize(width: CGFloat(camera.width), height: CGFloat(camera.height)),
//                               contentMode: .fill)
//                ProgressView()
//              }
//            }
//          )
//        }
//
//        HStack {
//          Spacer()
//          Image(systemName: "arrow.down")
//          Text("More info")
//          Image(systemName: "arrow.down")
//          Spacer()
//        }
//        Text("Mileage: \(statusFormatter.mileage(from: status))")
//          .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
      }
    }
    .onReceive(vehicle.statusPublisher
      .receive(on: RunLoop.main)
      .catch({ error in
        // TODO: Handle this as an enum type somehow so that we don't have to create a dummy status.
        return Just(VehicleModel.VehicleStatus(error: error))
      })
    ) { status in
      self.status = status
    }
  }
}
