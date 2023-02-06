import Foundation
import SwiftUI

struct NavigationLinkContentView: View {
  let imageSystemName: String
  let title: String

  var body: some View {
    HStack {
      Image(systemName: imageSystemName)
        .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 4))
      Text(title)
        .frame(maxWidth: .infinity, alignment: .leading)
      Spacer()
#if os(watchOS)
      Image(systemName: "chevron.forward")
#endif
    }
  }
}
