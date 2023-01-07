import Foundation
import Security

private let server = "login.porsche.com"

final class AuthStore {
  /// Stores the given username and password into the keychain.
  static func store(username: String, password: String) {
    let status: OSStatus
    if userAuth() != nil {
      let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrServer as String: server
      ]
      let updates: [String: Any] = [
        kSecAttrAccount as String: username,
        kSecValueData as String: password.data(using: .utf8)!
      ]
      status = SecItemUpdate(query as CFDictionary, updates as CFDictionary)
    } else {
      let query: [String: Any] = [
        kSecClass as String: kSecClassInternetPassword,
        kSecAttrAccount as String: username,
        kSecAttrServer as String: server,
        kSecValueData as String: password.data(using: .utf8)!
      ]
      status = SecItemAdd(query as CFDictionary, nil)
    }
    if status == errSecDuplicateItem {
      return
    }
    guard status == errSecSuccess else {
      fatalError(SecCopyErrorMessageString(status, nil)! as String)
    }
  }

  /// Fetches the username and password from the keychain, if they exist.
  static func userAuth() -> (username: String, password: String)? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassInternetPassword,
      kSecAttrServer as String: server,
      kSecMatchLimit as String: kSecMatchLimitOne,
      kSecReturnAttributes as String: true,
      kSecReturnData as String: true
    ]

    var item: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &item)
    guard status != errSecItemNotFound else {
      return nil
    }
    guard status == errSecSuccess else {
      fatalError(SecCopyErrorMessageString(status, nil)! as String)
    }
    guard let existingItem = item as? [String : Any],
          let passwordData = existingItem[kSecValueData as String] as? Data,
          let password = String(data: passwordData, encoding: String.Encoding.utf8),
          let account = existingItem[kSecAttrAccount as String] as? String
    else {
      fatalError("Missing data")
    }
    return (username: account, password: password)
  }
}
