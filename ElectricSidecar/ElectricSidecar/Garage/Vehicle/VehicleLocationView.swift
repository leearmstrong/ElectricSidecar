import Foundation
import PorscheConnect
import MapKit
import SwiftUI

private struct VehicleLocation: Identifiable {
  let id = UUID()
  var coordinate: CLLocationCoordinate2D
}

struct VehicleLocationView: View {
  let store: ModelStore
  enum LoadState {
    case error(error: Error)
    case loading
    case loaded(region: MKCoordinateRegion)
  }
  @State var loadState: LoadState = .loading
  @Binding var vehicle: Vehicle
  var body: some View {
    ZStack {
      switch loadState {
      case .loading:
        VStack(alignment: .leading) {
          ProgressView()
        }
      case .loaded(let region):
        Map(coordinateRegion: .constant(region), showsUserLocation: true, annotationItems: [
          VehicleLocation(coordinate: region.center)
        ]) { item in
          MapMarker(coordinate: item.coordinate, tint: .red)
        }
        .allowsHitTesting(false)
        .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fill)
      case .error(let error):
        VStack(alignment: .leading) {
          Text("Failed to load status")
          Text(error.localizedDescription)
        }
      }
    }
    .task {
      do {
        let position = try await store.position(for: vehicle)
        let region = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: position.carCoordinate.latitude,
                                         longitude: position.carCoordinate.longitude),
          latitudinalMeters: 200,
          longitudinalMeters: 200
        )
        loadState = .loaded(region: region)
      } catch {
        loadState = .error(error: error)
      }
    }
  }
}
