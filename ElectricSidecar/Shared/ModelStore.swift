import CryptoKit
import Foundation
import PorscheConnect

private let fm = FileManager.default

final class ModelStore: ObservableObject {
  private let porscheConnect: PorscheConnect
  private let authStorage: AuthStorage

  private let cacheURL: URL
  private let vehiclesURL: URL
  private let cacheTimeout: TimeInterval = 15 * 60

  init(username: String, password: String) {
    let folderURLs = FileManager.default.urls(
      for: .cachesDirectory,
      in: .userDomainMask
    )
    let hashed = SHA256.hash(data: username.data(using: .utf8)!)
    let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

    // Root cache directory
    self.cacheURL = folderURLs[0].appendingPathComponent(".cache").appendingPathComponent(hashString)
    if !fm.fileExists(atPath: cacheURL.path) {
      try! fm.createDirectory(at: cacheURL, withIntermediateDirectories: true)
    }

    // Auth tokens
    let authTokensURL = self.cacheURL.appendingPathComponent("auth_tokens")
    if !fm.fileExists(atPath: authTokensURL.path) {
      try! fm.createDirectory(at: authTokensURL, withIntermediateDirectories: true)
    }
    self.authStorage = AuthStorage(authTokensURL: authTokensURL)

    // Vehicle data
    self.vehiclesURL = self.cacheURL.appendingPathComponent("vehicles")

    porscheConnect = PorscheConnect(
      username: username,
      password: password,
      environment: Environment(locale: .current)!,
      authStorage: authStorage
    )
  }

  private func fileModificationDate(url: URL) -> Date? {
    do {
      let attr = try FileManager.default.attributesOfItem(atPath: url.path)
      return attr[FileAttributeKey.modificationDate] as? Date
    } catch {
      return nil
    }
  }

  func vehicleList(ignoreCache: Bool = false) async throws -> [Vehicle] {
    let url = cacheURL.appendingPathComponent("vehicleList")
    // Try disk cache first, if allowed.
    if !ignoreCache
        && fm.fileExists(atPath: url.path)
        && fileModificationDate(url: url)! > Date(timeIntervalSinceNow: -cacheTimeout) {
      let data = try! Data(contentsOf: url)
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode([Vehicle].self, from: data)
    }

    // Fetch data if we don't have it.
    let response = try await porscheConnect.vehicles()
    guard response.response.statusCode == 200,
          let vehicles = response.vehicles else {
      fatalError()
    }

    // Cache the response for next time.
    let jsonEncoder = JSONEncoder()
    let data = try jsonEncoder.encode(vehicles)
    try data.write(to: url)

    return vehicles
  }

  func capabilities(for vehicle: Vehicle, ignoreCache: Bool = false) async throws -> Capabilities {
    return try await get(vehicle: vehicle, cacheKey: "capabilities", ignoreCache: ignoreCache) { vehicle in
      let response = try await porscheConnect.capabilities(vehicle: vehicle)
      guard response.response.statusCode == 200,
            let result = response.capabilities else {
        fatalError()
      }
      return result
    }
  }

  func emobility(for vehicle: Vehicle, ignoreCache: Bool = false) async throws -> Emobility {
    let capabilities = try await capabilities(for: vehicle, ignoreCache: ignoreCache)
    return try await get(vehicle: vehicle, cacheKey: "emobility", ignoreCache: ignoreCache) { vehicle in
      let response = try await porscheConnect.emobility(vehicle: vehicle, capabilities: capabilities)
      guard response.response.statusCode == 200,
            let result = response.emobility else {
        fatalError()
      }
      return result
    }
  }

  func summary(for vehicle: Vehicle, ignoreCache: Bool = false) async throws -> Summary {
    return try await get(vehicle: vehicle, cacheKey: "summary", ignoreCache: ignoreCache) { vehicle in
      let response = try await porscheConnect.summary(vehicle: vehicle)
      guard response.response.statusCode == 200,
            let result = response.summary else {
        fatalError()
      }
      return result
    }
  }

  func position(for vehicle: Vehicle, ignoreCache: Bool = false) async throws -> Position {
    return try await get(vehicle: vehicle, cacheKey: "position", ignoreCache: ignoreCache) { vehicle in
      let response = try await porscheConnect.position(vehicle: vehicle)
      guard response.response.statusCode == 200,
            let result = response.position else {
        fatalError()
      }
      return result
    }
  }

  func status(for vehicle: Vehicle, ignoreCache: Bool = false) async throws -> Status {
    return try await get(vehicle: vehicle, cacheKey: "status", ignoreCache: ignoreCache) { vehicle in
      let response = try await porscheConnect.status(vehicle: vehicle)
      guard response.response.statusCode == 200,
            let result = response.status else {
        fatalError()
      }
      return result
    }
  }

  private func get<T: Codable>(
    vehicle: Vehicle,
    cacheKey: String,
    ignoreCache: Bool = false,
    api: (Vehicle) async throws -> T
  ) async throws -> T {
    // Try disk cache first.
    let vehicleURL = vehiclesURL.appendingPathComponent(vehicle.vin)
    let url = vehicleURL.appendingPathComponent(cacheKey)
    if !fm.fileExists(atPath: vehicleURL.path) {
      try fm.createDirectory(at: vehicleURL, withIntermediateDirectories: true)
    }
    if !ignoreCache
        && fm.fileExists(atPath: url.path)
        && fileModificationDate(url: url)! > Date(timeIntervalSinceNow: -cacheTimeout) {
      let data = try! Data(contentsOf: url)
      let jsonDecoder = JSONDecoder()
      return try jsonDecoder.decode(T.self, from: data)
    }

    // Fetch data if we don't have it.
    let result = try await api(vehicle)

    // Cache the response for next time.
    let jsonEncoder = JSONEncoder()
    let data = try jsonEncoder.encode(result)
    try data.write(to: url)

    return result
  }

  func flash(vehicle: Vehicle) async throws {
    let response = try await porscheConnect.flash(vehicle: vehicle)
    guard response.response.statusCode == 200 else {
      fatalError()
    }
  }
}

private final class AuthStorage: AuthStoring {
  private var authTokens: [String: OAuthToken] = [:]
  private let authTokensURL: URL
  init(authTokensURL: URL) {
    self.authTokensURL = authTokensURL
  }

  func storeAuthentication(token: OAuthToken?, for key: String) {
    // Write the token to disk
    let encoder = JSONEncoder()
    let data = try! encoder.encode(token)
    try! data.write(to: authTokenUrl(key: key))

    authTokens[key] = token
  }

  func authentication(for key: String) -> OAuthToken? {
    // Prioritize in-memory tokens.
    if let token = authTokens[key] {
      return token
    }

    // Fall-back to reading from disk.
    let jsonDecoder = JSONDecoder()
    let apiURL = authTokenUrl(key: key)
    if fm.fileExists(atPath: apiURL.path) {
      if let data = try? Data(contentsOf: apiURL),
         let token = try? jsonDecoder.decode(OAuthToken.self, from: data) {
        authTokens[key] = token
        return token
      }
    }

    // No token able to be loaded from memory or disk.
    return nil
  }

  private func authTokenUrl(key: String) -> URL {
    return authTokensURL.appendingPathComponent(key)
  }
}
