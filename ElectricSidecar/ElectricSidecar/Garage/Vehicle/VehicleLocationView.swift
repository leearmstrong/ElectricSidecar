import Foundation
import PorscheConnect
import MapKit
import SwiftUI

private struct VehicleLocation: Identifiable {
  let id = UUID()
  var coordinate: CLLocationCoordinate2D
}

struct VehicleLocationView: View {
  @Binding var position: UIModel.Vehicle.Position?
  var body: some View {
    if let position {
      Map(
        coordinateRegion: .constant(position.coordinateRegion),
        showsUserLocation: true,
        annotationItems: [
          VehicleLocation(coordinate: position.coordinateRegion.center)
        ]
      ) { item in
        MapMarker(coordinate: item.coordinate, tint: .red)
      }
      .allowsHitTesting(false)
      .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fill)
    } else {
      ProgressView()
    }
  }
}

// Note: MapKit crashes SwiftUI previews so the only preview here
// is intentionally just checking the nil state.
struct VehicleLocationView_Previews: PreviewProvider {
  static var previews: some View {
    VehicleLocationView(position: .constant(nil))
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Series 8 45mm")
  }
}
