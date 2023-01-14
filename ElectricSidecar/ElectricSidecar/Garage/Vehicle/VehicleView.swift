import CachedAsyncImage
import Combine
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleView: View {
  let vehicle: UIModel.Vehicle

  let statusPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Status>, Never>
  let emobilityPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Emobility>, Never>
  let positionPublisher: AnyPublisher<UIModel.Refreshable<UIModel.Vehicle.Position>, Never>
  let refresh: () async throws -> Void

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
          RefreshStatusView(
            statusRefreshing: $statusRefreshing,
            emobilityRefreshing: $emobilityRefreshing,
            positionRefreshing: $positionRefreshing
          )
          .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
        } else {
          Button("refresh") {
            withAnimation {
              isRefreshing = true
              statusRefreshing = true
              emobilityRefreshing = true
              positionRefreshing = true
            }
            Task {
              try await refresh()
              withAnimation {
                isRefreshing = false
              }
            }
          }
          .padding()
        }

        VehicleDetailsView(
          modelDescription: vehicle.modelDescription,
          modelYear: vehicle.modelYear,
          vin: vehicle.vin
        )

        if let statusError {
          Text(statusError.localizedDescription)
        }
        if let emobilityError {
          Text(emobilityError.localizedDescription)
        }
        if let positionError {
          Text(positionError.localizedDescription)
        }
      }
    }
    .onReceive(statusPublisher.receive(on: RunLoop.main)) { result in
      status = result.value
      statusError = result.error
      statusRefreshing = false
    }
    .onReceive(emobilityPublisher.receive(on: RunLoop.main)) { result in
      emobility = result.value
      emobilityError = result.error
      emobilityRefreshing = false
    }
    .onReceive(positionPublisher.receive(on: RunLoop.main)) { result in
      position = result.value
      positionError = result.error
      positionRefreshing = false
    }
  }
}
