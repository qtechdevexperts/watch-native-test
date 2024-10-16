import Foundation
import WatchConnectivity
import WatchKit

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var isConnected = false
    private var session: WCSession?
    private var backgroundRefreshInterval: TimeInterval = 1 * 60 // 1 minutes

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("Watch: WCSession activation requested")
        } else {
            print("Watch: WatchConnectivity is not supported on this device.")
        }
    }

    func scheduleBackgroundRefresh() {
        WKExtension.shared().scheduleBackgroundRefresh(withPreferredDate: Date().addingTimeInterval(backgroundRefreshInterval), userInfo: nil) { error in
            if let error = error {
                print("Watch: Failed to schedule background refresh: \(error.localizedDescription)")
            } else {
                print("Watch: Background refresh scheduled")
            }
        }
    }

    func performBackgroundRefresh() {
        checkConnectionStatus()
        scheduleBackgroundRefresh()
    }

    private func checkConnectionStatus() {
        if let session = session {
            let isActive = session.activationState == .activated
            let isCompanionAppInstalled = session.isCompanionAppInstalled
            
            DispatchQueue.main.async {
                self.isConnected = isActive && isCompanionAppInstalled
            }
            
            print("Watch: Connection status - Active: \(isActive), Companion App Installed: \(isCompanionAppInstalled), Activation State: \(session.activationState.rawValue)")
        } else {
            DispatchQueue.main.async {
                self.isConnected = false
            }
            print("Watch: WCSession is not initialized")
        }
    }

    func sendMessageToPhone(message: [String: Any]) {
        if let session = session, session.isReachable {
            session.sendMessage(message, replyHandler: { reply in
                print("Watch: Received reply from iPhone: \(reply)")
            }) { error in
                print("Watch: Error sending message to iPhone: \(error.localizedDescription)")
            }
        } else {
            print("Watch: iPhone is not reachable")
        }
    }

    func syncConnectionStatus() {
        sendMessageToPhone(message: ["requestConnectionStatus": true])
    }

    // MARK: - WCSessionDelegate Methods

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("Watch: WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("Watch: WCSession activated with state: \(activationState.rawValue)")
        print("Watch: Is companion app installed: \(session.isCompanionAppInstalled)")
        checkConnectionStatus()
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        print("Watch: Received message from iPhone: \(message)")
        if message["requestConnectionStatus"] as? Bool == true {
            replyHandler(["isConnected": isConnected])
        } else {
            replyHandler(["response": "Message received on Watch"])
        }
        checkConnectionStatus()
    }
}
