import Foundation
import PorscheConnect

extension Vehicle: Identifiable {
  public var id: String {
    return vin
  }
}
