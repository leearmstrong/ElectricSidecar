import Foundation
import SwiftUI

struct RadialProgressView: View {
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
