import Foundation
import PorscheConnect
import SwiftUI

struct VehicleDetailsView: View {
  @Binding var status: UIModel.Vehicle.Status?
  var modelDescription: String
  var modelYear: String
  var vin: String

  var body: some View {
    VStack(alignment: .leading) {
      if let status {
        Text("Mileage: \(status.mileage)")
          .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
      }
      Text("\(modelDescription) (\(modelYear))")
      Text(vin)
    }
  }
}

struct VehicleDetailsView_Previews: PreviewProvider {
  static let status = UIModel.Vehicle.Status(
    batteryLevel: 100,
    electricalRange: "100 miles",
    mileage: "100 miles",
    doors: UIModel.Vehicle.Doors(
      frontLeft: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      frontRight: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      backLeft: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      backRight: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true),
      frontTrunk: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true),
      backTrunk: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      overallLockStatus: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true)
    )
  )
  static var previews: some View {
    VehicleDetailsView(
      status: .constant(status),
      modelDescription: "Taycan",
      modelYear: "2022",
      vin: "ABC123"
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Series 8 45mm")
  }
}
