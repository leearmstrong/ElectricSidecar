import Foundation
import SwiftUI
import WatchConnectivity

@main
struct ElectricSidecarWidgets: WidgetBundle {
  @WidgetBundleBuilder
  var body: some Widget {
    VehicleChargeWidget()
    VehicleRangeWidget()
#if !os(watchOS)
    ChargingLiveActivity()
#endif
  }
}
