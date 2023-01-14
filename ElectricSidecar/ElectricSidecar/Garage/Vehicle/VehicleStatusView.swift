import CachedAsyncImage
import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleStatusView: View {
  let vehicle: UIModel.Vehicle
  @Binding var status: UIModel.Vehicle.Status?
  @Binding var emobility: UIModel.Vehicle.Emobility?

  let statusFormatter = StatusFormatter()
  var cancellables = Set<AnyCancellable>()

  var body: some View {
    ZStack {
      VStack(alignment: .leading) {
        HStack {
          Text(vehicle.licensePlate ?? "\(vehicle.modelDescription) (\(vehicle.modelYear))")
            .font(.title2)
          Spacer()
          if let status {
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
        HStack(spacing: 0) {
          if let emobility, let status {
            if emobility.isCharging == true {
              Text(Image(systemName: "bolt.fill"))
            }
            Text(status.batteryLevel)
            if let electricalRange = status.electricalRange {
              Text(", \(electricalRange)")
            }
            Spacer()
          } else {
            ProgressView()
          }
        }

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

        if let status {
          HStack {
            Spacer()
            Image(systemName: "arrow.down")
            Text("More info")
            Image(systemName: "arrow.down")
            Spacer()
          }
          Text("Mileage: \(status.mileage))")
            .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
        }
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
      status: .constant(nil),
      emobility: .constant(nil)
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
      status: .constant(nil),
      emobility: .constant(nil)
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
      status: .constant(nil),
      emobility: .constant(nil)
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loading / Long license")
  }
}

struct VehicleStatusView_Loaded_Previews: PreviewProvider {
  static let status = UIModel.Vehicle.Status(
    isLocked: true,
    isClosed: true,
    batteryLevel: "100%",
    electricalRange: "100 miles",
    mileage: "100 miles"
  )
  static let emobility = UIModel.Vehicle.Emobility(
    isCharging: true
  )
  static var previews: some View {
    VehicleStatusView(
      vehicle: UIModel.Vehicle(
        vin: "ABC",
        modelDescription: "Taycan",
        modelYear: "2022"
      ),
      status: .constant(Self.status),
      emobility: .constant(Self.emobility)
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
      status: .constant(Self.status),
      emobility: .constant(Self.emobility)
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
      status: .constant(Self.status),
      emobility: .constant(Self.emobility)
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loaded / Long license")
  }
}
