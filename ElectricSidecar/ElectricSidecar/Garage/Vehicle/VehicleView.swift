import CachedAsyncImage
import ClockKit
import Combine
import Foundation
import OSLog
import PorscheConnect
import SwiftUI
import WidgetKit

struct VehicleView: View {
  let vehicle: UIModel.Vehicle

  let statusPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Status>, Never>
  let emobilityPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never>
  let positionPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Position>, Never>


  let refreshCallback: (Bool) async throws -> Void
  let lockCallback: () async throws -> Void
  let unlockCallback: () async throws -> Void

  @State var status: UIModel.Vehicle.Status?
  @State var emobility: UIModel.Vehicle.Emobility?
  @State var position: UIModel.Vehicle.Position?
  @State var statusError: Error?
  @State var emobilityError: Error?
  @State var positionError: Error?

  @State var statusRefreshing: Bool = false
  @State var emobilityRefreshing: Bool = false
  @State var positionRefreshing: Bool = false

  @State private var isRefreshing = false
  @State private var isChangingLockState = false

  var body: some View {
    ScrollView {
      VStack(alignment: .center) {

        HStack {
          ZStack {
            if !isChangingLockState {
              Button {
                Task {
                  logger.info("Unlocking \(vehicle.vin, privacy: .private)")
                  isChangingLockState = true
                  defer {
                    isChangingLockState = false
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

          ChargeView(status: $status, emobility: $emobility)
            .padding(.top, 8)

          ZStack {
            if !isChangingLockState {
              Button {
                Task {
                  logger.info("Locking \(vehicle.vin, privacy: .private)")
                  isChangingLockState = true
                  defer {
                    isChangingLockState = false
                  }
                  try await lockCallback()
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
            withAnimation {
              isRefreshing = true
              statusRefreshing = true
              emobilityRefreshing = true
              positionRefreshing = true
            }
            Task {
              defer {
                withAnimation {
                  statusRefreshing = false
                  emobilityRefreshing = false
                  positionRefreshing = false
                  isRefreshing = false
                }
              }
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
    .onAppear {
      isRefreshing = true
      statusRefreshing = true
      emobilityRefreshing = true
      positionRefreshing = true
      Task {
        defer {
          withAnimation {
            statusRefreshing = false
            emobilityRefreshing = false
            positionRefreshing = false
            isRefreshing = false
          }
        }
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

  private func refresh(ignoreCache: Bool) async throws {
    try await refreshCallback(ignoreCache)

    logger.info("Refreshing all widget timelines")
    WidgetCenter.shared.reloadAllTimelines()
  }
}
