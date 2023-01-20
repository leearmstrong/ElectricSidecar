import Combine
import CryptoKit
import Foundation
import MapKit
import PorscheConnect
import os

private let fm = FileManager.default

extension FileManager {
  static var sharedContainerURL: URL {
    return FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: APP_GROUP_IDENTIFIER
    )!
  }
}

public let logger = Logger(subsystem: LOGGER_SUBSYSTEM, category: "network")

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
      environment: Environment(locale: SupportedLocale.default)!,
      authStorage: authStorage
    )
  }

  // MARK: - Combine-based cache warming

  func load() async throws {
    logger.info("Initial load")
    let vehicles: [Vehicle]
    do {
      vehicles = try await vehicleList()
    } catch {
      logger.error("Failed initial load with error: \(error, privacy: .public)")
      throw error
    }

    logger.debug("Loaded \(vehicles.count, privacy: .public) vehicles")
    let vehicleModels = vehicles.map { vehicle in
      return UIModel.Vehicle(
        vin: vehicle.vin,
        licensePlate: vehicle.licensePlate,
        modelDescription: vehicle.modelDescription,
        modelYear: vehicle.modelYear,
        color: vehicle.color,
        personalizedPhoto: vehicle.personalizedPhoto,
        externalPhotos: vehicle.pictures ?? []
      )
    }

    await MainActor.run {
      logger.log(level: .debug, "Vehicles provided to model")
      self.vehicles = vehicleModels
    }
  }

  private var refreshState: [String: Bool] = [:]
  func refresh(vin: String, ignoreCache: Bool = false) async throws {
    logger.info("Refresh state attempt for \(vin, privacy: .private(mask: .hash))")
    if refreshState[vin] == true {
      return  // Already refreshing.
    }
    refreshState[vin] = true

    logger.info("Starting refresh task group for \(vin, privacy: .private(mask: .hash))")

    // TODO: Keep an in-memory cache of the last-known status.
    await withTaskGroup(of: Void.self, body: { taskGroup in
      taskGroup.addTask {
        do {
          logger.info("Refreshing status for \(vin, privacy: .private(mask: .hash))")
          let status = try await self.status(for: vin, ignoreCache: ignoreCache)
          let statusFormatter = StatusFormatter()
          self.statusSubject(for: vin).send(.loaded(UIModel.Vehicle.Status(
            isLocked: status.isLocked,
            isClosed: status.isClosed,
            batteryLevel: status.batteryLevel.value,
            batteryLevelFormatted: statusFormatter.batteryLevel(from: status),
            electricalRange: statusFormatter.electricalRange(from: status),
            mileage: statusFormatter.mileage(from: status)
          )))
          logger.info("Finished refreshing status for \(vin, privacy: .private(mask: .hash))")
        } catch {
          logger.error("Status failed \(error, privacy: .public)")
          self.statusSubjects[vin]?.send(.error(error))
        }
      }
      taskGroup.addTask {
        do {
          logger.info("Refreshing emobility for \(vin, privacy: .private(mask: .hash))")
          let emobility = try await self.emobility(for: vin, ignoreCache: ignoreCache)
          self.emobilitySubject(for: vin).send(.loaded(UIModel.Vehicle.Emobility(
            isCharging: emobility.isCharging
          )))
          logger.info("Finished refreshing emobility for \(vin, privacy: .private(mask: .hash))")
        } catch {
          logger.error("Status failed \(error, privacy: .public)")
          self.emobilitySubjects[vin]?.send(.error(error))
        }
      }
      taskGroup.addTask {
        do {
          logger.info("Refreshing position for \(vin, privacy: .private(mask: .hash))")
          let position = try await self.position(for: vin, ignoreCache: ignoreCache)
          let coordinateRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: position.carCoordinate.latitude,
                                           longitude: position.carCoordinate.longitude),
            latitudinalMeters: 200,
            longitudinalMeters: 200
          )
          self.positionSubject(for: vin).send(.loaded(UIModel.Vehicle.Position(
            coordinateRegion: coordinateRegion
          )))
          logger.info("Finished refreshing position for \(vin, privacy: .private(mask: .hash))")
        } catch {
          logger.error("Status failed \(error, privacy: .public)")
          self.positionSubjects[vin]?.send(.error(error))
        }
      }
    })
    logger.info("Finished refreshing \(vin, privacy: .private(mask: .hash))")
    refreshState[vin] = false
  }

  private var statusSubjects: [String: any Subject<UIModel.Refreshable<UIModel.Vehicle.Status>, Never>] = [:]
  private func statusSubject(for vin: String) -> any Subject<UIModel.Refreshable<UIModel.Vehicle.Status>, Never> {
    if let subject = statusSubjects[vin] {
      return subject
    }
    let subject = CurrentValueSubject<UIModel.Refreshable<UIModel.Vehicle.Status>, Never>(.loading)
    statusSubjects[vin] = subject
    return subject
  }
  func statusPublisher(for vin: String) -> AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Status>, Never> {
    return statusSubject(for: vin).eraseToAnyPublisher()
  }

  private var emobilitySubjects: [String: any Subject<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never>] = [:]
  private func emobilitySubject(for vin: String) -> any Subject<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never> {
    if let subject = emobilitySubjects[vin] {
      return subject
    }
    let subject = CurrentValueSubject<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never>(.loading)
    emobilitySubjects[vin] = subject
    return subject
  }
  func emobilityPublisher(for vin: String) -> AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never> {
    return emobilitySubject(for: vin).eraseToAnyPublisher()
  }

  private var positionSubjects: [String: any Subject<UIModel.Refreshable<UIModel.Vehicle.Position>, Never>] = [:]
  private func positionSubject(for vin: String) -> any Subject<UIModel.Refreshable<UIModel.Vehicle.Position>, Never> {
    if let subject = positionSubjects[vin] {
      return subject
    }
    let subject = CurrentValueSubject<UIModel.Refreshable<UIModel.Vehicle.Position>, Never>(.loading)
    positionSubjects[vin] = subject
    return subject
  }
  func positionPublisher(for vin: String) -> AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Position>, Never> {
    return positionSubject(for: vin).eraseToAnyPublisher()
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

  func status(for vin: String, ignoreCache: Bool = false) async throws -> Status {
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

/// This actor type ensures that all storage/retrieval of auth tokens happens in a thread-safe manner.
private actor AuthStoreActor {
  private var authTokens: [String: OAuthToken] = [:]

  func storeAuthentication(token: OAuthToken?, for key: String) {
    authTokens[key] = token
  }

  func authentication(for key: String) async -> OAuthToken? {
    return authTokens[key]
  }
}

private final class AuthStorage: AuthStoring {
  private let actor = AuthStoreActor()
  private let authTokensURL: URL
  private let cacheCoordinator: CodableCacheCoordinator
  init(authTokensURL: URL, fileCoordinator: CodableCacheCoordinator) {
    self.authTokensURL = authTokensURL
    self.cacheCoordinator = fileCoordinator
  }

  func storeAuthentication(token: OAuthToken?, for key: String) async throws {
    let url = authTokenUrl(key: key)
    try cacheCoordinator.encode(url: url, object: token)
    await actor.storeAuthentication(token: token, for: key)
  }

  func authentication(for key: String) async -> OAuthToken? {
    // Prioritize in-memory tokens.
    if let token = await actor.authentication(for: key) {
      return token
    }

    let url = authTokenUrl(key: key)
    if let token: OAuthToken = try! cacheCoordinator.decode(url: url) {
      await actor.storeAuthentication(token: token, for: key)
      return token
    }

    // No token able to be loaded from memory or disk.
    return nil
  }

  private func authTokenUrl(key: String) -> URL {
    return authTokensURL.appendingPathComponent(key)
  }
}
