import Foundation

extension UIModel {
  enum Refreshable<T> {
    case loading
    case refreshing(lastKnown: T?)
    case loaded(T)
    case error(error: Error, lastKnown: T?)
  }
}
