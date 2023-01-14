import Foundation
import SwiftUI

struct RefreshStatusView: View {
  @State var statusRefreshing: Bool = false
  @State var emobilityRefreshing: Bool = false
  @State var positionRefreshing: Bool = false

  var body: some View {
    HStack(alignment: .top) {
      VStack {
        Image(systemName: "info.circle")
        ProgressView()
          .opacity(statusRefreshing ? 1 : 0)
          .animation(.linear, value: statusRefreshing)
      }
      .frame(maxWidth: .infinity)
      VStack {
        Image(systemName: "bolt.car")
        ProgressView()
          .opacity(emobilityRefreshing ? 1 : 0)
          .animation(.linear, value: emobilityRefreshing)
      }
      .frame(maxWidth: .infinity)
      VStack {
        Image(systemName: "location")
        ProgressView()
          .opacity(positionRefreshing ? 1 : 0)
          .animation(.linear, value: positionRefreshing)
      }
      .frame(maxWidth: .infinity)
    }
  }
}

struct RefreshStatusView_Previews: PreviewProvider {
  static var previews: some View {
    RefreshStatusView(
      statusRefreshing: true,
      emobilityRefreshing: true,
      positionRefreshing: true
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Series 8 45mm")
  }
}
