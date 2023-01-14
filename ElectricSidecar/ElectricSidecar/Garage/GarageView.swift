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
            VehicleView(vehicle: vehicle)
          }
        }
        .tabViewStyle(.page)
      } else {
        ProgressView()
      }
    }
  }
}
