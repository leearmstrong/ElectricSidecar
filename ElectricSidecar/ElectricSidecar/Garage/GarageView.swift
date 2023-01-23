import PorscheConnect
import OSLog
import SwiftUI

struct GarageView: View {
  @SwiftUI.Environment(\.scenePhase) var scenePhase
  @StateObject var store: ModelStore
  let authFailure: (Error) -> Void

  enum LoadState {
    case error(error: Error)
    case loadingVehicles
    case loaded
  }

  @State var lastRefresh: Date = .now
  @State var isLogReadingEnabled: Bool = false

  @State var loadState: LoadState = .loadingVehicles
  var body: some View {
    NavigationStack {
      if let vehicles = store.vehicles {
        TabView {
          ForEach(vehicles) { vehicle in
            VehicleView(
              vehicle: vehicle,
              statusPublisher: store.statusPublisher(for: vehicle.vin),
              emobilityPublisher: store.emobilityPublisher(for: vehicle.vin),
              positionPublisher: store.positionPublisher(for: vehicle.vin)
            ) { ignoreCache in
              try await store.refresh(vin: vehicle.vin, ignoreCache: ignoreCache)
              lastRefresh = .now
            } lockCallback: {
              guard let commandToken = try await store.lock(vin: vehicle.vin) else {
                return nil
              }

              var lastStatus = try await store.checkStatus(
                vin: vehicle.vin,
                remoteCommand: commandToken
              )?.remoteStatus
              while lastStatus == .inProgress {
                // Avoid excessive API calls.
                try await Task.sleep(nanoseconds: UInt64(0.5 * Double(NSEC_PER_SEC)))

                lastStatus = try await store.checkStatus(
                  vin: vehicle.vin,
                  remoteCommand: commandToken
                )?.remoteStatus
              }

              if let lastActions = try await store.lockUnlockLastActions(vin: vehicle.vin) {
                return lastActions.doors.overallLockStatus
              } else {
                return nil
              }
            } unlockCallback: {
              print("Unlock the car...")
            }
          }
          if isLogReadingEnabled {
            LogsView()
          }
        }
        .tabViewStyle(.page)
      } else {
        ProgressView()
      }
    }
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active,
         let vehicles = store.vehicles,
         lastRefresh < .now.addingTimeInterval(-15 * 60) {
        Task {
          for vehicle in vehicles {
            try await store.refresh(vin: vehicle.vin, ignoreCache: true)
          }
          lastRefresh = .now
        }
      }
    }
    .task(priority: .background) {
      do {
        isLogReadingEnabled = try checkIfLogReadingIsEnabled()
      } catch {
        isLogReadingEnabled = false
      }
    }
  }

  func checkIfLogReadingIsEnabled() throws -> Bool {
    let subsystem = "group.com.featherless.electricsidecar.testlogger"
    let testLogger = Logger(subsystem: subsystem, category: "test")
    testLogger.error("test")
    let startTime = Date(timeIntervalSinceNow: -5)
    let logStore = try OSLogStore(scope: .currentProcessIdentifier)
    let predicate = NSPredicate(format: "subsystem == %@", argumentArray: [subsystem])
    let position = logStore.position(date: startTime)
    return try logStore.getEntries(at: position, matching: predicate).makeIterator().next() != nil
  }
}
