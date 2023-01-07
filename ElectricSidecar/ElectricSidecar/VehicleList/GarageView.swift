import PorscheConnect
import SwiftUI

struct GarageView: View {
  let store: ModelStore
  let authFailure: (Error) -> Void

  enum LoadState {
    case error(error: Error)
    case loadingVehicles
    case loaded
  }
  @State var loadState: LoadState = .loadingVehicles
  @State var vehicles: [Vehicle] = []
  var body: some View {
    NavigationStack {
      switch loadState {
      case .loadingVehicles:
        ProgressView()
      case  .loaded:
        VehiclesTabView(store: store, vehicles: $vehicles)
      case .error(let error):
        VStack {
          Text("Failed to load vehicles")
          Text(error.localizedDescription)
        }
      }
    }
    .task {
      do {
        vehicles = try await store.vehicleList()
        loadState = .loaded
      } catch {
        loadState = .error(error: error)
        authFailure(error)
      }
    }
  }
}
