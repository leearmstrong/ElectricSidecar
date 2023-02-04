import ActivityKit
import WidgetKit
import SwiftUI

struct ChargingLiveActivity: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: ChargingActivityAttributes.self) { context in
      // Lock screen/banner UI goes here
      VStack {
        Text(Self.formatted(chargeRemaining: context.state.batteryPercent))
      }
      .activityBackgroundTint(BatteryStyle.batteryColor(for: context.state.batteryPercent))
      .activitySystemActionForegroundColor(Color.black)

    } dynamicIsland: { context in
      DynamicIsland {
        // Expanded UI goes here.  Compose the expanded UI through
        // various regions, like leading/trailing/center/bottom
        DynamicIslandExpandedRegion(.leading) {
          Text(Self.formatted(chargeRemaining: context.state.batteryPercent))
        }
        DynamicIslandExpandedRegion(.trailing) {
          Text("Trailing")
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text("Bottom")
          // more content
        }
      } compactLeading: {
        Text(Self.formatted(chargeRemaining: context.state.batteryPercent))
      } compactTrailing: {
        Text(Self.formatted(chargeRemaining: context.state.batteryPercent))
      } minimal: {
        Text(Self.formatted(chargeRemaining: context.state.batteryPercent, includePercent: false))
      }
      .widgetURL(URL(string: "http://www.apple.com"))
      .keylineTint(Color.red)
    }
  }

  static func formatted(chargeRemaining: Double, includePercent: Bool = true) -> String {
    return String(format: "%.0f", chargeRemaining) + (includePercent ? "%" : "")
  }
}

struct ChargingLiveActivity_Previews: PreviewProvider {
  static let attributes = ChargingActivityAttributes()
  static let contentState = ChargingActivityAttributes.ContentState(batteryPercent: 80)

  static var previews: some View {
    attributes
      .previewContext(contentState, viewKind: .dynamicIsland(.compact))
      .previewDisplayName("Island Compact")
    attributes
      .previewContext(contentState, viewKind: .dynamicIsland(.expanded))
      .previewDisplayName("Island Expanded")
    attributes
      .previewContext(contentState, viewKind: .dynamicIsland(.minimal))
      .previewDisplayName("Minimal")
    attributes
      .previewContext(contentState, viewKind: .content)
      .previewDisplayName("Notification")
  }
}


