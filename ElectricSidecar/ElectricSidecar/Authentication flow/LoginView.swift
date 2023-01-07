import SwiftUI

struct LoginView: View {
  @Binding var email: String
  @Binding var password: String
  let didLogin: () -> Void

  var body: some View {
    VStack {
      TextField("Email", text: $email)
        .textContentType(.emailAddress)
        .textInputAutocapitalization(.never)
        .multilineTextAlignment(.center)
        .font(.body)
      SecureField("Password", text: $password)
        .textContentType(.password)
        .multilineTextAlignment(.center)
      Button("Log in", action: didLogin)
        .disabled(email.isEmpty || password.isEmpty)
    }
    .padding()
  }
}

// MARK: - Previews

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    ContainerView()
      .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 8 (45mm)"))
      .previewDisplayName("Series 8 45mm")

    ContainerView()
      .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 8 (41mm)"))
      .previewDisplayName("Series 8 41mm")

    ContainerView()
      .previewDevice(PreviewDevice(rawValue: "Apple Watch Ultra (49mm)"))
      .previewDisplayName("Ultra 49mm")

    ContainerView()
      .previewDevice(PreviewDevice(rawValue: "Apple Watch Series 5 (40mm)"))
      .previewDisplayName("Series 5 40mm")
  }

  struct ContainerView : View {
    @State var email: String = ""
    @State var password: String = ""

    var body: some View {
      LoginView(email: $email, password: $password) {
        print("Did login")
      }
    }
  }
}
