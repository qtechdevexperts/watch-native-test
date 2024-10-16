import Foundation
import WatchConnectivity

class iOSWatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var isConnected = false
    private var session: WCSession?

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
            print("iOS: WCSession activation requested")
        } else {
            print("iOS: WatchConnectivity is not supported on this device.")
        }
    }

    private func updateConnectionStatus() {
        DispatchQueue.main.async {
            self.isConnected = self.session?.isReachable ?? false
        }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Watch received message: \(message)")
        // Handle the message as needed
    }
    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("iOS: WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("iOS: WCSession activated with state: \(activationState.rawValue)")
        updateConnectionStatus()
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("iOS: Watch reachability changed. Reachable: \(session.isReachable)")
        updateConnectionStatus()
    }

    #if os(iOS)
    // These methods are required for iOS
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("iOS: Session became inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("iOS: Session deactivated, reactivating...")
        WCSession.default.activate()
    }
    #endif

    // Example method to send a message to the watch
    func sendMessageToWatch(message: [String: Any]) {
        if let session = session, session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("iOS: Error sending message to watch: \(error.localizedDescription)")
            }
        } else {
            print("iOS: Watch is not reachable")
        }
    }
}
