import Foundation
import PorscheConnect
import SwiftUI

struct VehicleDetailsView: View {
  var modelDescription: String
  var modelYear: String
  var vin: String

  var body: some View {
    VStack(alignment: .leading) {
      Text("\(modelDescription) (\(modelYear))")
      Text(vin)
    }
  }
}

struct VehicleDetailsView_Previews: PreviewProvider {
  static var previews: some View {
    VehicleDetailsView(
      modelDescription: "Taycan",
      modelYear: "2022",
      vin: "ABC123"
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Series 8 45mm")
  }
}
