import Foundation
import ActivityKit

struct ChargingActivityAttributes: ActivityAttributes {
  public typealias ChargeStatus = ContentState

  public struct ContentState: Codable, Hashable {
    var batteryPercent: Double
  }
}
