import Foundation
import os

let LOGGER_SUBSYSTEM = "com.featherless.electricsidecar.logging"

public final class Logging {
  public static let network = Logger(subsystem: LOGGER_SUBSYSTEM, category: "network")
  public static let watchConnectivity = Logger(subsystem: LOGGER_SUBSYSTEM, category: "watch-connectivity")
}
