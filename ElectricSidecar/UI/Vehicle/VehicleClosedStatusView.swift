import Foundation
import SwiftUI

struct VehicleClosedStatusView: View {
  var doors: UIModel.Vehicle.Doors?

  var body: some View {
    HStack {
      if let doors {
        Image(systemName: doors.overallLockStatus.isLocked == true ? "lock.fill" : "lock.open.fill")
        ZStack {
          if doors.frontTrunk.isOpen {
            Text(Image(systemName: "car.side.front.open"))
          }
          if doors.backTrunk.isOpen {
            Text(Image(systemName: "car.side.rear.open"))
              .padding(.leading, 2)
          }
        }
        if let carImageName {
          Text(Image(systemName: carImageName))
        }
      } else {
        ProgressView()
      }
    }
    .font(.title3)
  }

  var carImageName: String? {
    guard let doors else {
      return nil
    }
    var openDoors: [String] = []
    if doors.frontLeft.isOpen {
      openDoors.append("front.left")
    }
    if doors.frontRight.isOpen {
      openDoors.append("front.right")
    }
    if doors.backLeft.isOpen {
      openDoors.append("rear.left")
    }
    if doors.backRight.isOpen {
      openDoors.append("rear.right")
    }
    if openDoors.count == 0 {
      return nil
    }
    return "car.top.door.\(openDoors.joined(separator: ".and.")).open"
  }
}

struct VehicleClosedStatusView_Previews: PreviewProvider {
  static var previews: some View {
    VehicleClosedStatusView(doors: UIModel.Vehicle.Doors(
      frontLeft: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      frontRight: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      backLeft: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      backRight: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true),
      frontTrunk: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true),
      backTrunk: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      overallLockStatus: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true)
    ))
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Loading / No license")
  }
}
