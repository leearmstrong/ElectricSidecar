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
  }

#if os(iOS)
  func sessionDidBecomeInactive(_ session: WCSession) {
    Logging.watchConnectivity.info("sessionDidBecomeInactive \(session)")
  }

  func sessionDidDeactivate(_ session: WCSession) {
    Logging.watchConnectivity.info("sessionDidDeactivate \(session)")
  }
#endif

  // MARK: - Message handling

  func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
    Logging.watchConnectivity.info("session(_: didReceiveMessage: \(message))")
  }

  func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
    Logging.watchConnectivity.info("session(_: didFinish: \(userInfoTransfer) - \(userInfoTransfer.userInfo), error: \(error)")
  }

  func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
    Logging.watchConnectivity.info("session(_: didReceiveUserInfo: \(userInfo))")
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
