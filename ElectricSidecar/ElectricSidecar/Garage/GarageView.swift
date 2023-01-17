import PorscheConnect
import SwiftUI

struct GarageView: View {
  @SwiftUI.Environment(\.scenePhase) var scenePhase
  @StateObject var store: ModelStore
  let authFailure: (Error) -> Void

  enum LoadState {
    case error(error: Error)
    case loadingVehicles
    case loaded
  }

  @State var lastRefresh: Date = .now

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
            ) { ignoreCache in
              try await store.refresh(vin: vehicle.vin, ignoreCache: ignoreCache)
              lastRefresh = .now
            }
          }
        }
        .tabViewStyle(.page)
      } else {
        ProgressView()
      }
    }
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active,
         let vehicles = store.vehicles,
         lastRefresh < .now.addingTimeInterval(-15 * 60) {
        Task {
          for vehicle in vehicles {
            try await store.refresh(vin: vehicle.vin, ignoreCache: true)
          }
          lastRefresh = .now
        }
      }
    }
  }
}
