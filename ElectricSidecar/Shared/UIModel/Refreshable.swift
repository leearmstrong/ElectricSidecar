import Foundation

extension UIModel {
  struct Refreshable<T> {
    let value: T?
    let error: Error?

    static var loading: Self {
      Refreshable(value: nil, error: nil)
    }
    static func loaded(_ value: T) -> Self {
      return Refreshable(value: value, error: nil)
    }
    static func error(_ error: Error) -> Self {
      return Refreshable(value: nil, error: error)
    }
  }
}
