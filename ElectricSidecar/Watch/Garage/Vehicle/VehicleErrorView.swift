import Foundation
import SwiftUI

struct VehicleErrorView: View {
  @Binding var statusError: Error?
  @Binding var emobilityError: Error?
  @Binding var positionError: Error?

  var body: some View {
    if let statusError {
      Text(statusError.localizedDescription)
    }
    if let emobilityError {
      Text(emobilityError.localizedDescription)
    }
    if let positionError {
      Text(positionError.localizedDescription)
    }
  }
}
