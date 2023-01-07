import Foundation
import PorscheConnect
import SwiftUI

struct VehiclesTabView: View {
  let store: ModelStore
  @Binding var vehicles: [Vehicle]
  var body: some View {
    TabView {
      ForEach($vehicles) { vehicle in
        VehicleView(store: store, vehicle: vehicle)
      }
    }
    .tabViewStyle(.page)
  }
}
