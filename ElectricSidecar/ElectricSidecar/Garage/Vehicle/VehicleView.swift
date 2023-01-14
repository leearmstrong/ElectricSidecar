import CachedAsyncImage
import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleView: View {
  let vehicle: UIModel.Vehicle
  @State var status: UIModel.Vehicle.Status?
  @State var emobility: UIModel.Vehicle.Emobility?
  @State var position: UIModel.Vehicle.Position?
  let statusPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Status>, Never>
  let emobilityPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never>
  let positionPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Position>, Never>
  let refresh: () async throws -> Void

  @State private var isRefreshing = false

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        VehicleStatusView(vehicle: vehicle, status: $status, emobility: $emobility)
        VehicleLocationView(position: $position)
          .padding(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))

        if let camera = vehicle.personalizedPhoto {
          CachedAsyncImage(
            url: camera.url,
            urlCache: .imageCache,
            content: { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            },
            placeholder: {
              ZStack {
                (vehicle.color ?? .gray)
                  .aspectRatio(CGSize(width: CGFloat(camera.width), height: CGFloat(camera.height)),
                               contentMode: .fill)
                ProgressView()
              }
            }
          )
        }

        if isRefreshing {
          ProgressView()
            .padding()
        } else {
          Button("refresh") {
            isRefreshing = true
            Task {
              try await refresh()
              isRefreshing = false
            }
          }
          .padding()
        }

        VehicleDetailsView(
          modelDescription: vehicle.modelDescription,
          modelYear: vehicle.modelYear,
          vin: vehicle.vin
        )
      }
    }
    .onReceive(statusPublisher
      .receive(on: RunLoop.main)
    ) { result in
      // TODO: This enum can probably just be a struct with both an optional value and optional error.
      switch result {
      case .loading:
        self.status = nil
      case .loaded(let status):
        self.status = status
      case .refreshing(let status):
        self.status = status
      case .error(_, let lastKnown):
        self.status = lastKnown
        // TODO: Show the error state somehow.
      }
    }
    .onReceive(emobilityPublisher
      .receive(on: RunLoop.main)
    ) { result in
      // TODO: This enum can probably just be a struct with both an optional value and optional error.
      switch result {
      case .loading:
        self.emobility = nil
      case .loaded(let emobility):
        self.emobility = emobility
      case .refreshing(let emobility):
        self.emobility = emobility
      case .error(_, let lastKnown):
        self.emobility = lastKnown
        // TODO: Show the error state somehow.
      }
    }
    .onReceive(positionPublisher
      .receive(on: RunLoop.main)
    ) { result in
      // TODO: This enum can probably just be a struct with both an optional value and optional error.
      switch result {
      case .loading:
        self.emobility = nil
      case .loaded(let position):
        self.position = position
      case .refreshing(let position):
        self.position = position
      case .error(_, let lastKnown):
        self.position = lastKnown
        // TODO: Show the error state somehow.
      }
    }
  }
}
