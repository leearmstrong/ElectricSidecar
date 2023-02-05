import Foundation
import WatchConnectivity

extension Notification.Name {
  static let activationDidComplete = Notification.Name("ActivationDidComplete")
  static let reachabilityDidChange = Notification.Name("ReachabilityDidChange")
}

final class WatchConnectivityObserver: NSObject, WCSessionDelegate {
  // MARK: - Connectivity state observation

  func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    let activationStateDescription = [
      WCSessionActivationState.notActivated: "Not activated",
      WCSessionActivationState.activated: "Activated",
      WCSessionActivationState.inactive: "Inactive",
    ][activationState]!
    Logging.watchConnectivity.info("session(_:activationDidCompleteWith: \(activationStateDescription) error: \(error))")

    if activationState == .activated {
      postNotificationOnMainQueueAsync(name: .activationDidComplete)
    }
  }

  func sessionReachabilityDidChange(_ session: WCSession) {
    Logging.watchConnectivity.info("sessionReachabilityDidChange() reachable: \(session.isReachable)")

    postNotificationOnMainQueueAsync(name: .reachabilityDidChange)
  }

#if os(iOS)
  func sessionWatchStateDidChange(_ session: WCSession) {
    Logging.watchConnectivity.info("sessionWatchStateDidChange \(session)")
  }

  func sessionDidBecomeInactive(_ session: WCSession) {
    Logging.watchConnectivity.info("sessionDidBecomeInactive \(session)")
  }

  func sessionDidDeactivate(_ session: WCSession) {
    Logging.watchConnectivity.info("sessionDidDeactivate \(session)")
    session.activate()
  }
#endif

  // MARK: - Message handling

  func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
    if message["request"] as? String == "auth-credentials" {
      replyHandler([
        "email": AUTH_MODEL.email,
        "password": AUTH_MODEL.password,
      ])
      return
    }

    // Default case
    replyHandler([:])
  }
}

// MARK: - Utilities

extension WatchConnectivityObserver {
  fileprivate func postNotificationOnMainQueueAsync(name: NSNotification.Name, object: Any? = nil) {
    DispatchQueue.main.async {
      NotificationCenter.default.post(name: name, object: object)
    }
  }
}
