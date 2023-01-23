import CachedAsyncImage
import ClockKit
import Combine
import Foundation
import OSLog
import PorscheConnect
import SwiftUI
import WidgetKit

struct VehicleView: View {
  @SwiftUI.Environment(\.scenePhase) var scenePhase

  let vehicle: UIModel.Vehicle

  let statusPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Status>, Never>
  let emobilityPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never>
  let positionPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Position>, Never>

  @State var lastRefresh: Date = .now
  let refreshCallback: (Bool) async throws -> Void
  let lockCallback: () async throws -> Doors.DoorStatus?
  let unlockCallback: () async throws -> Void

  @MainActor @State var status: UIModel.Vehicle.Status?
  @MainActor @State var emobility: UIModel.Vehicle.Emobility?
  @MainActor @State var position: UIModel.Vehicle.Position?
  @MainActor @State var statusError: Error?
  @MainActor @State var emobilityError: Error?
  @MainActor @State var positionError: Error?

  @MainActor @State var statusRefreshing: Bool = false
  @MainActor @State var emobilityRefreshing: Bool = false
  @MainActor @State var positionRefreshing: Bool = false

  @MainActor @State private var isRefreshing = false
  @MainActor @State private var isChangingLockState = false

  var body: some View {
    ScrollView {
      VStack(alignment: .center) {

        HStack {
          // Unlock
          ZStack {
            if !isChangingLockState {
              Button {
                Task {
                  logger.info("Unlocking \(vehicle.vin, privacy: .private)")
                  isChangingLockState = true
                  defer {
                    Task {
                      await MainActor.run {
                        isChangingLockState = false
                      }
                    }
                  }
                  try await unlockCallback()
                }
              } label: {
                Image(systemName: "lock.open")
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .buttonStyle(.plain)
            } else {
              ProgressView()
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)

          ChargeView(
            batteryLevel: status?.batteryLevel,
            isCharging: emobility?.isCharging,
            allowsAnimation: true
          )
          .frame(width: 65, height: 65)
          .padding(.top, 8)

          // Lock
          ZStack {
            if !isChangingLockState {
              Button {
                Task {
                  logger.info("Locking \(vehicle.vin, privacy: .private)")
                  isChangingLockState = true
                  defer {
                    Task {
                      await MainActor.run {
                        isChangingLockState = false
                      }
                    }
                  }
                  if let doorStatus = try await lockCallback() {
                    switch doorStatus {
                    case .closedAndLocked:
                      status?.isLocked = true
                      status?.isClosed = true
                    case .closedAndUnlocked:
                      status?.isLocked = false
                      status?.isClosed = true
                    case .openAndUnlocked:
                      status?.isLocked = false
                      status?.isClosed = false
                    }
                  }
                }
              } label: {
                Image(systemName: "lock")
                  .frame(maxWidth: .infinity, maxHeight: .infinity)
              }
              .buttonStyle(.plain)
            } else {
              ProgressView()
            }
          }
          .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        if let electricalRange = status?.electricalRange {
          Text(electricalRange)
            .font(.footnote)
            .padding(.top, -10)
        }

        Spacer(minLength: 32)

        if isRefreshing {
          RefreshStatusView(
            statusRefreshing: $statusRefreshing,
            emobilityRefreshing: $emobilityRefreshing,
            positionRefreshing: $positionRefreshing
          )
          .padding(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        } else {
          Button("Refresh") {
            Task {
              try await refresh(ignoreCache: true)
            }
          }
        }

        NavigationLink {
          VehicleDetailsView(
            status: $status,
            modelDescription: vehicle.modelDescription,
            modelYear: vehicle.modelYear,
            vin: vehicle.vin
          )
          .navigationTitle("Details")
        } label: {
          NavigationLinkContentView(imageSystemName: "info.circle", title: "More details")
        }
        NavigationLink {
          VehiclePhotosView(vehicle: vehicle)
            .navigationTitle("Photos")
        } label: {
          NavigationLinkContentView(imageSystemName: "photo.on.rectangle.angled", title: "Photos")
        }

        VehicleLocationView(
          vehicleName: vehicle.licensePlate ?? vehicle.modelDescription,
          position: $position
        )
        .padding(.zero)

        if statusError != nil || emobilityError != nil || positionError != nil {
          NavigationLink {
            if let statusError {
              Text(statusError.localizedDescription)
            }
            if let emobilityError {
              Text(emobilityError.localizedDescription)
            }
            if let positionError {
              Text(positionError.localizedDescription)
            }
          } label: {
            NavigationLinkContentView(imageSystemName: "exclamationmark.triangle", title: "Errors")
          }
        }
      }
    }
    .navigationTitle(vehicle.licensePlate ?? "\(vehicle.modelDescription) (\(vehicle.modelYear))")
    .onChange(of: scenePhase) { newPhase in
      if newPhase == .active, lastRefresh < .now.addingTimeInterval(-15 * 60) {
        Task {
          try await refresh(ignoreCache: true)
        }
      }
    }
    .onAppear {
      Task {
        try await refresh(ignoreCache: false)
      }
    }
    .onReceive(statusPublisher.receive(on: RunLoop.main)) { result in
      status = result.value
      statusError = result.error

      if result.value != nil || result.error != nil {
        statusRefreshing = false
      }
    }
    .onReceive(emobilityPublisher.receive(on: RunLoop.main)) { result in
      emobility = result.value
      emobilityError = result.error

      if result.value != nil || result.error != nil {
        emobilityRefreshing = false
      }
    }
    .onReceive(positionPublisher.receive(on: RunLoop.main)) { result in
      position = result.value
      positionError = result.error

      if result.value != nil || result.error != nil {
        positionRefreshing = false
      }
    }
  }

  static func formatted(chargeRemaining: Double) -> String {
    let formatter = NumberFormatter()
    formatter.locale = Locale.current
    formatter.numberStyle = .percent
    formatter.maximumFractionDigits = 0
    return formatter.string(from: chargeRemaining as NSNumber)!
  }

  @MainActor
  private func refresh(ignoreCache: Bool) async throws {
    isRefreshing = true
    statusRefreshing = true
    emobilityRefreshing = true
    positionRefreshing = true

    Task {
      defer {
        Task {
          await MainActor.run {
            withAnimation {
              statusRefreshing = false
              emobilityRefreshing = false
              positionRefreshing = false
              isRefreshing = false
            }
            logger.info("Refreshing all widget timelines")
            WidgetCenter.shared.reloadAllTimelines()
          }
        }
      }
      try await refreshCallback(ignoreCache)
      lastRefresh = .now
    }
  }
}
