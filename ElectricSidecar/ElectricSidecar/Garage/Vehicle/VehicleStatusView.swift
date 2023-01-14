import CachedAsyncImage
import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleStatusView: View {
  let vehicle: UIModel.Vehicle
  @Binding var status: UIModel.Vehicle.Status?

  let statusFormatter = StatusFormatter()
  var cancellables = Set<AnyCancellable>()

  var body: some View {
    ZStack {
      VStack(alignment: .leading) {
        HStack {
          Text(vehicle.licensePlate ?? "\(vehicle.modelDescription) (\(vehicle.modelYear))")
            .font(.title2)
          Spacer()
          if let status = status {
            if let isLocked = status.isLocked {
              Image(systemName: isLocked ? "lock" : "lock.open")
                .font(.body)
            }
            if let isClosed = status.isClosed {
              Image(systemName: isClosed ? "door.left.hand.closed" : "door.left.hand.open")
            }
          } else {
            ProgressView()
              .frame(maxWidth: 30)
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
  }
}

struct VehicleStatusView_Loading_Previews: PreviewProvider {
  static var previews: some View {
    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(nil)
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loading / No license")

    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        licensePlate: "Journey",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(nil)
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loading / Short license")

    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        licensePlate: "Journey of the featherless",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(nil)
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loading / Long license")
  }
}

struct VehicleStatusView_Loaded_Previews: PreviewProvider {
  static var previews: some View {
    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(UIModel.Vehicle.Status(isLocked: true, isClosed: true))
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loaded / No license")

    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        licensePlate: "Journey",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(UIModel.Vehicle.Status(isLocked: true, isClosed: true))
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loaded / Short license")

    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        licensePlate: "Journey of the featherless",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(UIModel.Vehicle.Status(isLocked: true, isClosed: true))
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loaded / Long license")
  }
}
