import CachedAsyncImage
import Foundation
import PorscheConnect
import SwiftUI

struct VehicleStatusView: View {
  let store: ModelStore
  enum LoadState {
    case error(error: Error)
    case loading
    case loaded(status: Status, emobility: Emobility)
  }
  @State var loadState: LoadState = .loading
  @Binding var vehicle: Vehicle
  let statusFormatter = StatusFormatter()
  var body: some View {
    ZStack {
      switch loadState {
      case .loading:
        VStack(alignment: .leading) {
          ProgressView()
        }
      case .loaded(let status, let emobility):
        VStack(alignment: .leading) {
          HStack {
            Text(vehicle.licensePlate ?? "\(vehicle.modelDescription) (\(vehicle.modelYear))")
              .font(.title2)
            Spacer()
            if let isLocked = status.isLocked {
              Image(systemName: isLocked ? "lock" : "lock.open")
                .font(.body)
            }
            if let isClosed = status.isClosed {
              Image(systemName: isClosed ? "door.left.hand.closed" : "door.left.hand.open")
            }
          }
          HStack(spacing: 0) {
            if emobility.isCharging == true {
              Text(Image(systemName: "bolt.fill"))
            }
            Text(statusFormatter.batteryLevel(from: status))
            if let remainingRange = statusFormatter.electricalRange(from: status) {
              Text(", \(remainingRange)")
            }
            Spacer()
          }

          if let camera = vehicle.externalCamera(.front, size: 2) {
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

          HStack {
            Spacer()
            Image(systemName: "arrow.down")
            Text("More info")
            Image(systemName: "arrow.down")
            Spacer()
          }
          Text("Mileage: \(statusFormatter.mileage(from: status))")
            .padding(EdgeInsets(top: 4, leading: 0, bottom: 0, trailing: 0))
        }
      case .error(let error):
        VStack(alignment: .leading) {
          Text("Failed to load status")
          Text(error.localizedDescription)
        }
      }
    }
    .task {
      do {
        let status = try await store.status(for: vehicle)
        let emobility = try await store.emobility(for: vehicle)
        loadState = .loaded(status: status, emobility: emobility)
      } catch {
        loadState = .error(error: error)
      }
    }
  }
}
