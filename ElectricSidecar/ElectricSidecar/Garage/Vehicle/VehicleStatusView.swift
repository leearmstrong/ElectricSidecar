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
    HStack(spacing: 0) {
      if let status {
        if let electricalRange = status.electricalRange {
          Text(", \(electricalRange)")
        }
        Spacer()
      } else {
        ProgressView()
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
    batteryLevel: 100,
    batteryLevelFormatted: "100%",
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
