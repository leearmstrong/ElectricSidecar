import Foundation
import SwiftUI

struct DoorStatusView: View {
  let isLocked: Bool?
  let isClosed: Bool?

  var body: some View {
    HStack {
      if let isLocked {
        Image(systemName: isLocked ? "lock" : "lock.open")
      }
      if let isClosed {
        Image(systemName: isClosed ? "door.left.hand.closed" : "door.left.hand.open")
      }
    }
  }
}
