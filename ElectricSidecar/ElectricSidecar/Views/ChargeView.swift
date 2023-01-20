import Foundation
import SwiftUI


private struct ChargeCircleView: View {
  let scale: Double
  let color: Color
  private let lineWidth: Double = 6
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
  @Binding var status: UIModel.Vehicle.Status?
  @Binding var emobility: UIModel.Vehicle.Emobility?

  @State var pulseIsOn: Bool = false

  private let lineWidth: Double = 6
  private let orientation: Angle = .degrees(135)
  private let fillRatio: Double = 0.75

  var chargeColor: Color? {
    guard let batteryLevel = status?.batteryLevel else {
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
      if let emobility, let status, let chargeColor {
        ChargeCircleView(scale: 1, color: chargeColor.opacity(0.2))
        if emobility.isCharging == true {
          ChargeCircleView(
            scale: status.batteryLevel * 0.01,
            color: pulseIsOn ? chargeColor : chargeColor.opacity(0.5)
          )
          .animation(.easeInOut(duration: 1.25).repeatForever(autoreverses: true), value: pulseIsOn)
          .onAppear {
            pulseIsOn = true
          }
        } else {
          ChargeCircleView(scale: status.batteryLevel * 0.01, color: .green)
        }

        VStack {
          Image(emobility.isCharging == true ? "taycan.charge" : "taycan")
            .font(.title2)
            .padding(.top, 10)
          Text(status.batteryLevelFormatted)
            .font(.footnote)
        }
      } else {
        ChargeCircleView(scale: 1, color: .gray)
        Image("taycan")
          .foregroundColor(.gray)
          .font(.title2)
          .padding(.top, -4)
      }
    }
    .frame(width: 65, height: 65)
  }
}

struct ChargeView_Previews: PreviewProvider {
  static let status = UIModel.Vehicle.Status(
    isLocked: true,
    isClosed: true,
    batteryLevel: 70,
    batteryLevelFormatted: "20%",
    electricalRange: "100 miles",
    mileage: "100 miles"
  )
  static let emobility = UIModel.Vehicle.Emobility(
    isCharging: true
  )
  static var previews: some View {
    HStack {
      Spacer()
      ChargeView(
        status: .constant(Self.status),
        emobility: .constant(Self.emobility)
      )
      Spacer()
    }
    .previewDevice("Apple Watch Series 8 (45mm)")
  }
}
