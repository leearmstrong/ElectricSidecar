import Foundation
import SwiftUI

private struct ChargeCircleView: View {
  let scale: Double
  let color: Color
  let lineWidth: Double
  private let orientation: Angle = .degrees(135)
  private let fillRatio: Double = 0.75

  var body: some View {
    Circle()
      .trim(from: 0, to: fillRatio * scale)
      .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
      .rotationEffect(orientation)
  }
}

struct ChargeView: View {
  @Environment(\.widgetRenderingMode) var renderingMode

  var batteryLevel: Double?
  var isCharging: Bool?

  var allowsAnimation = false
  @State var pulseIsOn = true

  var lineWidth: Double = 6
  private let orientation: Angle = .degrees(135)
  private let fillRatio: Double = 0.75

  var chargeColor: Color? {
    guard let batteryLevel else {
      return nil
    }
    if batteryLevel <= 15 {
      return .red
    }
    if batteryLevel <= 30 {
      return .orange
    }
    if batteryLevel <= 50 {
      return .yellow
    }
    return .green
  }

  var body: some View {
    ZStack {
      if let batteryLevel, let batteryLevelFormatted, let isCharging, let chargeColor {
        // Gutter
        ChargeCircleView(
          scale: 1,
          color: chargeColor.opacity(0.2),
          lineWidth: lineWidth
        )

        // Fill
        ChargeCircleView(
          scale: batteryLevel * 0.01,
          color: pulseIsOn ? chargeColor : chargeColor.opacity(0.5),
          lineWidth: lineWidth
        )
        .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: pulseIsOn)
        .onAppear {
          guard allowsAnimation, isCharging else {
            return
          }
          pulseIsOn = false
        }
        .widgetAccentable(true)

        VStack {
          Image(isCharging == true ? "taycan.charge" : "taycan")
            .font(.title2)
            .padding(.top, 10)
          Text(batteryLevelFormatted)
            .font(.footnote)
        }
      } else {
        ChargeCircleView(
          scale: 1,
          color: .gray,
          lineWidth: lineWidth
        )
        Image("taycan")
          .foregroundColor(.gray)
          .font(.title2)
          .padding(.top, -4)
      }
    }
  }

  var batteryLevelFormatted: String? {
    guard let batteryLevel else {
      return nil
    }
    return String(format: "%.0f%%", batteryLevel)
  }
}

struct ChargeView_Previews: PreviewProvider {
  static let status = UIModel.Vehicle.Status(
    batteryLevel: 70,
    electricalRange: "100 miles",
    mileage: "100 miles",
    doors: UIModel.Vehicle.Doors(
      frontLeft: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      frontRight: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      backLeft: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      backRight: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true),
      frontTrunk: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true),
      backTrunk: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: false),
      overallLockStatus: UIModel.Vehicle.Doors.Status(isLocked: true, isOpen: true)
    )
  )
  static let emobility = UIModel.Vehicle.Emobility(
    isCharging: true
  )
  static var previews: some View {
    HStack {
      Spacer()
      ChargeView(
        batteryLevel: 20,
        isCharging: true
      )
      Spacer()
    }
    .previewDevice("Apple Watch Series 8 (45mm)")
  }
}
