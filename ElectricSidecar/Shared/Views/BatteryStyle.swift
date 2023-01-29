import Foundation
import SwiftUI

struct BatteryStyle {
  static func batteryColor(for chargeRemaining: Double?) -> Color {
    guard let chargeRemaining else {
      return .gray
    }
    if chargeRemaining >= 75 {
      return .green
    } else if chargeRemaining >= 50 {
      return .yellow
    } else if chargeRemaining > 20 {
      return .orange
    } else {
      return .red
    }
  }
}
