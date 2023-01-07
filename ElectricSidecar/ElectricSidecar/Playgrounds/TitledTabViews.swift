import Foundation
import SwiftUI

// A demo of a multi-tab view with different navigation titles on each tab.
struct TestTabBehavior_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TabView {
        Color(.red).navigationTitle("Red")
        Color(.blue).navigationTitle("Blue")
        Color(.green).navigationTitle("Green")
      }
      .tabViewStyle(.page)
    }
  }
}
