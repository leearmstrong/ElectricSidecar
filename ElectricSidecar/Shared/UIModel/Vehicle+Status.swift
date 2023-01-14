import Foundation

extension UIModel.Vehicle {
  struct Status {
    let isLocked: Bool?
    let isClosed: Bool?

    init(isLocked: Bool? = nil, isClosed: Bool? = nil) {
      self.isLocked = isLocked
      self.isClosed = isClosed
    }
  }
}
