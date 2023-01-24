import Foundation
import SwiftUI

struct RefreshStatusView: View {
  @Binding var statusRefreshing: Bool
  @Binding var emobilityRefreshing: Bool
  @Binding var positionRefreshing: Bool
  @Binding var doorsRefreshing: Bool

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
        Image("taycan.charge")
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
      VStack {
        Image(systemName: "car.top.door.front.left.and.front.right.and.rear.left.and.rear.right.open")
        ProgressView()
          .opacity(doorsRefreshing ? 1 : 0)
          .animation(.linear, value: doorsRefreshing)
      }
      .frame(maxWidth: .infinity)
    }
  }
}

struct RefreshStatusView_Previews: PreviewProvider {
  static var previews: some View {
    RefreshStatusView(
      statusRefreshing: .constant(true),
      emobilityRefreshing: .constant(true),
      positionRefreshing: .constant(true),
      doorsRefreshing: .constant(true)
    )
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Series 8 45mm")
  }
}

struct Image_Previews: PreviewProvider {
  static var previews: some View {
    Image("taycan.charge")
      .symbolRenderingMode(.palette)
      .foregroundStyle(.orange, .blue, .green)
      .font(.largeTitle)
    .previewDevice("Apple Watch Series 8 (45mm)")
    .previewDisplayName("Taycan symbol")
  }
}
