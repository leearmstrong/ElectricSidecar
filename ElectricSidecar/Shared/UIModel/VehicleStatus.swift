import Foundation

struct VehicleStatus {
  let isLocked: Bool?
  let isClosed: Bool?

  init(isLocked: Bool? = nil, isClosed: Bool? = nil) {
    self.isLocked = isLocked
    self.isClosed = isClosed
    self.error = nil
  }

  let error: Error?
  init(error: Error) {
    self.isLocked = nil
    self.isClosed = nil
    self.error = error
  }
}
