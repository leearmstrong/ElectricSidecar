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
          .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        VehicleDetailsView(
          camera: vehicle.personalizedPhoto,
          vehicleColor: vehicle.color,
          modelDescription: vehicle.modelDescription,
          modelYear: vehicle.modelYear,
          vin: vehicle.vin
        )
          .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
      }
    }
  }
}
