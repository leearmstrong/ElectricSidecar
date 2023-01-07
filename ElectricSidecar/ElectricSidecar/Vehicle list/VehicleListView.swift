import CachedAsyncImage
import PorscheConnect
import MapKit
import SwiftUI

struct VehicleListView: View {
  let store: ModelStore
  let authFailure: (Error) -> Void

  enum LoadState {
    case error(error: Error)
    case loadingVehicles
    case loaded
  }
  @State var loadState: LoadState = .loadingVehicles
  @State var vehicles: [Vehicle] = []
  var body: some View {
    NavigationStack {
      switch loadState {
      case .loadingVehicles:
        ProgressView()
          .navigationTitle("Loading cars...")
      case  .loaded:
        ContentView(store: store, vehicles: $vehicles)
      case .error(let error):
        VStack {
          Text("Failed to load vehicles")
          Text(error.localizedDescription)
        }
      }
    }
    .task {
      do {
        vehicles = try await store.vehicleList()
        loadState = .loaded
      } catch {
        loadState = .error(error: error)
        authFailure(error)
      }
    }
  }
}

private struct VehicleDetailsView: View {
  @Binding var vehicle: Vehicle
  var body: some View {
    VStack(alignment: .leading) {
      CachedAsyncImage(
        url: vehicle.personalizedPhoto!.url,
        urlCache: .imageCache,
        content: { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
        },
        placeholder: {
          ZStack {
            Color(UIColor(hex: vehicle.exteriorColorHex!)!)
              .aspectRatio(CGSize(width: CGFloat(vehicle.personalizedPhoto!.width),
                                  height: CGFloat(vehicle.personalizedPhoto!.height)),
                           contentMode: .fill)
            ProgressView()
          }
        }
      )
      Text("\(vehicle.modelDescription) (\(vehicle.modelYear))")
      Text(vehicle.vin)
    }
  }
}

struct GaugeComplicationView: View {
  var batteryLevel: Double

  var body: some View {
    Gauge(value: batteryLevel, in: 0...100.0) {
      Text("ºF")
    } currentValueLabel: {
      Image(systemName: "bolt.car")
        .font(.system(.title3))
        .padding(.top, -4)
    } minimumValueLabel: {
      Text("")
    } maximumValueLabel: {
      Text(String(format: "%.0f", batteryLevel)) + Text("%").font(.system(.footnote))
    }
    .gaugeStyle(
      CircularGaugeStyle(tint:
                          Gradient(colors: [.red, .orange, .yellow, .green])))
  }
}

extension Status {
  /// Returns a human-readable representation of the vehicle's locked state.
  public var isLocked: Bool? {
    switch overallLockStatus {
    case "CLOSED_UNLOCKED":
      return false
    case "CLOSED_LOCKED":
      return true
    default:
      return nil
    }
  }

  /// Returns a human-readable representation of the open/closed state of the vehicle's doors.
  public var isClosed: Bool? {
    switch overallLockStatus {
    case "CLOSED_UNLOCKED":
      return true
    default:
      return nil
    }
  }
}

private struct VehicleStatusView: View {
  let store: ModelStore
  enum LoadState {
    case error(error: Error)
    case loading
    case loaded(status: Status)
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
      case .loaded(let status):
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
            Text(statusFormatter.batteryLevel(from: status))
            if let remainingRange = statusFormatter.electricalRange(from: status) {
              Text(", \(remainingRange)")
            }
            Spacer()
          }

          CachedAsyncImage(
            url: vehicle.externalCamera(.front, size: 2)!.url,
            urlCache: .imageCache,
            content: { image in
              image
                .resizable()
                .aspectRatio(contentMode: .fill)
            },
            placeholder: {
              ZStack {
                Color(UIColor(hex: vehicle.exteriorColorHex!)!)
                  .aspectRatio(CGSize(width: CGFloat(vehicle.personalizedPhoto!.width),
                                      height: CGFloat(vehicle.personalizedPhoto!.height)),
                               contentMode: .fill)
                ProgressView()
              }
            }
          )

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
        loadState = .loaded(status: try await store.status(for: vehicle))
      } catch {
        loadState = .error(error: error)
      }
    }
  }
}

struct VehicleLocation: Identifiable {
  let id = UUID()
  var coordinate: CLLocationCoordinate2D
}

private struct VehicleLocationView: View {
  let store: ModelStore
  enum LoadState {
    case error(error: Error)
    case loading
    case loaded(region: MKCoordinateRegion)
  }
  @State var loadState: LoadState = .loading
  @Binding var vehicle: Vehicle
  var body: some View {
    ZStack {
      switch loadState {
      case .loading:
        VStack(alignment: .leading) {
          ProgressView()
        }
      case .loaded(let region):
        Map(coordinateRegion: .constant(region), showsUserLocation: true, annotationItems: [
          VehicleLocation(coordinate: region.center)
        ]) { item in
          MapMarker(coordinate: item.coordinate, tint: .red)
        }
        .allowsHitTesting(false)
        .aspectRatio(CGSize(width: 2, height: 1), contentMode: .fill)
      case .error(let error):
        VStack(alignment: .leading) {
          Text("Failed to load status")
          Text(error.localizedDescription)
        }
      }
    }
    .task {
      do {
        let position = try await store.position(for: vehicle)
        let region = MKCoordinateRegion(
          center: CLLocationCoordinate2D(latitude: position.carCoordinate.latitude,
                                         longitude: position.carCoordinate.longitude),
          latitudinalMeters: 200,
          longitudinalMeters: 200
        )
        loadState = .loaded(region: region)
      } catch {
        loadState = .error(error: error)
      }
    }
  }
}

private struct VehicleView: View {
  let store: ModelStore
  @Binding var vehicle: Vehicle

  var body: some View {
    ScrollView {
      VStack(alignment: .leading) {
        VehicleStatusView(store: store, vehicle: $vehicle)
        VehicleLocationView(store: store, vehicle: $vehicle)
          .padding(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
        VehicleDetailsView(vehicle: $vehicle)
          .padding(EdgeInsets(top: 16, leading: 0, bottom: 0, trailing: 0))
      }
    }
  }
}

private struct ContentView: View {
  let store: ModelStore
  @Binding var vehicles: [Vehicle]
  var body: some View {
    TabView {
      ForEach($vehicles) { vehicle in
        VehicleView(store: store, vehicle: vehicle)
      }
    }
    .tabViewStyle(.page)
  }
}

extension UIColor {
  public convenience init?(hex: String) {
    let r, g, b: CGFloat

    if hex.hasPrefix("#") {
      let start = hex.index(hex.startIndex, offsetBy: 1)
      let hexColor = String(hex[start...])

      if hexColor.count == 6 {
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt64 = 0

        if scanner.scanHexInt64(&hexNumber) {
          r = CGFloat((hexNumber & 0xff0000) >> 16) / 255
          g = CGFloat((hexNumber & 0x00ff00) >> 8) / 255
          b = CGFloat((hexNumber & 0x0000ff)) / 255

          self.init(red: r, green: g, blue: b, alpha: 1)
          return
        }
      }
    }

    return nil
  }
}

extension Vehicle: Identifiable {
  public var id: String {
    return vin
  }
}

extension Vehicle {
  var licensePlate: String? {
    return attributes?.first(where: { attribute in
      attribute.name == "licenseplate"
    })?.value
  }
  var personalizedPhoto: VehiclePicture? {
    return pictures?.first(where: { picture in
      picture.view == "personalized" && picture.size == 2
    })
  }
  enum Camera: String {
    case front = "extcam01"
    case side = "extcam02"
    case rear = "extcam03"
    case topAngled = "extcam04"
    case overhead = "extcam05"
    case dashboard = "intcam01"
    case cabin = "intcam02"
  }
  func externalCamera(_ camera: Camera, size: Int) -> VehiclePicture? {
    return pictures?.first(where: { picture in
      picture.view == camera.rawValue && picture.size == size
    })
  }
}

struct TestTabBehavior_Previews: PreviewProvider {
  static var previews: some View {
    NavigationStack {
      TabView {
        Color(.red).navigationTitle("Red")
        Color(.blue).navigationTitle("Blue")
        Color(.green).navigationTitle("Green")
      }
      .tabViewStyle(.page)
    }
  }
}
