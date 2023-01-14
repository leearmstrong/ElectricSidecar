import Combine
import CryptoKit
import Foundation
import PorscheConnect

private let fm = FileManager.default

extension FileManager {
  static var sharedContainerURL: URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: APP_GROUP_IDENTIFIER
    )!
  }
}

final class ModelStore: ObservableObject {
  private let porscheConnect: PorscheConnect
  private let authStorage: AuthStorage
  private let cacheCoordinator = CodableCacheCoordinator()

  private let cacheURL: URL
  private let vehiclesURL: URL
  private let cacheTimeout: TimeInterval = 15 * 60
  private let longCacheTimeout: TimeInterval = 60 * 60 * 24 * 365

  @Published var vehicles: [UIModel.Vehicle]?

  init(username: String, password: String) {
    let baseURL = FileManager.sharedContainerURL
    let hashed = SHA256.hash(data: username.data(using: .utf8)!)
    let hashString = hashed.compactMap { String(format: "%02x", $0) }.joined()

    // Root cache directory
    self.cacheURL = baseURL.appendingPathComponent(".cache").appendingPathComponent(hashString)
    if !fm.fileExists(atPath: cacheURL.path) {
      try! fm.createDirectory(at: cacheURL, withIntermediateDirectories: true)
    }

    // Auth tokens
    let authTokensURL = self.cacheURL.appendingPathComponent("auth_tokens")
    if !fm.fileExists(atPath: authTokensURL.path) {
      try! fm.createDirectory(at: authTokensURL, withIntermediateDirectories: true)
    }
    self.authStorage = AuthStorage(authTokensURL: authTokensURL, fileCoordinator: cacheCoordinator)

    // Vehicle data
    self.vehiclesURL = self.cacheURL.appendingPathComponent("vehicles")

    porscheConnect = PorscheConnect(
      username: username,
      password: password,
      environment: Environment(locale: .current)!,
      authStorage: authStorage
    )
  }

  // MARK: - Combine-based cache warming

  func load() async throws {
    let vehicles = try await vehicleList()

    let vehicleModels = vehicles.map { vehicle in
      return UIModel.Vehicle(
        vin: vehicle.vin,
        licensePlate: vehicle.licensePlate,
        modelDescription: vehicle.modelDescription,
        modelYear: vehicle.modelYear,
        color: vehicle.color,
        personalizedPhoto: vehicle.personalizedPhoto
      )
    }

    await MainActor.run {
      self.vehicles = vehicleModels
    }
  }

  func refresh(vin: String) async throws {
    do {
      let output = try await self.status(for: vin)
      self.statusSubjects[vin]?.send(UIModel.Vehicle.Status(isLocked: output.isLocked, isClosed: output.isClosed))
    } catch {
      statusSubjects[vin]?.send(.init(error: error))
    }
  }

  private var statusSubjects: [String: any Subject<UIModel.Vehicle.Status, Error>] = [:]
  func statusPublisher(for vin: String) -> AnyPublisher<UIModel.Vehicle.Status, Error> {
    if let publisher = statusSubjects[vin] {
      return publisher.eraseToAnyPublisher()
    }
    let publisher = PassthroughSubject<UIModel.Vehicle.Status, Error>()
    statusSubjects[vin] = publisher
    Task {
      // Kick off the initial load.
      try await refresh(vin: vin)
    }
    return publisher.eraseToAnyPublisher()
  }

  // MARK: - API invocations

  func vehicleList(ignoreCache: Bool = false) async throws -> [Vehicle] {
    let url = cacheURL.appendingPathComponent("vehicleList")
    // Try disk cache first, if allowed.
    if !ignoreCache,
       let result: [Vehicle] = try cacheCoordinator.decode(url: url, timeout: cacheTimeout) {
      return result
    }

    // Fetch data if we don't have it.
    let response = try await porscheConnect.vehicles()
    guard response.response.statusCode == 200,
          let vehicles = response.vehicles else {
      fatalError()
    }

    try cacheCoordinator.encode(url: url, object: vehicles)

    return vehicles
  }

  func capabilities(for vin: String, ignoreCache: Bool = false) async throws -> Capabilities {
    return try await get(
      vin: vin,
      cacheKey: "capabilities",
      timeout: longCacheTimeout,
      ignoreCache: ignoreCache
    ) {
      let response = try await porscheConnect.capabilities(vin: vin)
      guard response.response.statusCode == 200,
            let result = response.capabilities else {
        fatalError()
      }
      return result
    }
  }

  func emobility(for vin: String, ignoreCache: Bool = false) async throws -> Emobility {
    let capabilities = try await capabilities(for: vin, ignoreCache: ignoreCache)
    return try await get(
      vin: vin,
      cacheKey: "emobility",
      timeout: cacheTimeout,
      ignoreCache: ignoreCache
    ) {
      let response = try await porscheConnect.emobility(vin: vin, capabilities: capabilities)
      guard response.response.statusCode == 200,
            let result = response.emobility else {
        fatalError()
      }
      return result
    }
  }

  func summary(for vin: String, ignoreCache: Bool = false) async throws -> Summary {
    return try await get(
      vin: vin,
      cacheKey: "summary",
      timeout: cacheTimeout,
      ignoreCache: ignoreCache
    ) {
      let response = try await porscheConnect.summary(vin: vin)
      guard response.response.statusCode == 200,
            let result = response.summary else {
        fatalError()
      }
      return result
    }
  }

  func position(for vin: String, ignoreCache: Bool = false) async throws -> Position {
    return try await get(
      vin: vin,
      cacheKey: "position",
      timeout: cacheTimeout,
      ignoreCache: ignoreCache
    ) {
      let response = try await porscheConnect.position(vin: vin)
      guard response.response.statusCode == 200,
            let result = response.position else {
        fatalError()
      }
      return result
    }
  }

  func status(for vin: String, ignoreCache: Bool = true) async throws -> Status {
    return try await get(
      vin: vin,
      cacheKey: "status",
      timeout: cacheTimeout,
      ignoreCache: ignoreCache
    ) {
      let response = try await porscheConnect.status(vin: vin)
      guard response.response.statusCode == 200,
            let result = response.status else {
        fatalError()
      }
      return result
    }
  }

  private func get<T: Codable>(
    vin: String,
    cacheKey: String,
    timeout: TimeInterval,
    ignoreCache: Bool = false,
    api: () async throws -> T
  ) async throws -> T {
    // Try disk cache first.
    let vehicleURL = vehiclesURL.appendingPathComponent(vin)
    let url = vehicleURL.appendingPathComponent(cacheKey)
    if !fm.fileExists(atPath: vehicleURL.path) {
      try fm.createDirectory(at: vehicleURL, withIntermediateDirectories: true)
    }
    if !ignoreCache,
       let result: T = try cacheCoordinator.decode(url: url, timeout: timeout) {
      return result
    }

    // Fetch data if we don't have it.
    let result = try await api()

    try cacheCoordinator.encode(url: url, object: result)

    return result
  }

  func flash(vin: String) async throws {
    let response = try await porscheConnect.flash(vin: vin)
    guard response.response.statusCode == 200 else {
      fatalError()
    }
  }
}

private final class AuthStorage: AuthStoring {
  private var authTokens: [String: OAuthToken] = [:]
  private let authTokensURL: URL
  private let cacheCoordinator: CodableCacheCoordinator
  init(authTokensURL: URL, fileCoordinator: CodableCacheCoordinator) {
    self.authTokensURL = authTokensURL
    self.cacheCoordinator = fileCoordinator
  }

  func storeAuthentication(token: OAuthToken?, for key: String) {
    let url = authTokenUrl(key: key)
    try! cacheCoordinator.encode(url: url, object: token)
    authTokens[key] = token
  }

  func authentication(for key: String) -> OAuthToken? {
    // Prioritize in-memory tokens.
    if let token = authTokens[key] {
      return token
    }

    let url = authTokenUrl(key: key)
    if let result: OAuthToken = try! cacheCoordinator.decode(url: url) {
      authTokens[key] = result
      return result
    }

    // No token able to be loaded from memory or disk.
    return nil
  }

  private func authTokenUrl(key: String) -> URL {
    return authTokensURL.appendingPathComponent(key)
  }
}
