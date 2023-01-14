import PorscheConnect
import SwiftUI

struct GarageView: View {
  @StateObject var store: ModelStore
  let authFailure: (Error) -> Void

  enum LoadState {
    case error(error: Error)
    case loadingVehicles
    case loaded
  }

  @State var loadState: LoadState = .loadingVehicles
  var body: some View {
    NavigationStack {
      if let vehicles = store.vehicles {
        TabView {
          ForEach(vehicles) { vehicle in
            VehicleView(
              vehicle: vehicle,
              statusPublisher: store.statusPublisher(for: vehicle.vin),
              emobilityPublisher: store.emobilityPublisher(for: vehicle.vin),
              positionPublisher: store.positionPublisher(for: vehicle.vin)
            ) {
              try await store.refresh(vin: vehicle.vin, ignoreCache: true)
            }
          }
        }
        .tabViewStyle(.page)
      } else {
        ProgressView()
      }
    }
  }
}
