import Foundation
import WatchConnectivity
//import watchKit

class iOSWatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var isConnected = false
    private var session: WCSession?
    @Published var showDisconnectionNotification = false

    init(session:WCSession = .default) {
        self.session = session
        super.init()
//        setupWatchConnectivity()
        session.delegate = self
        session.activate()
    }

//    func setupWatchConnectivity() {
//        if WCSession.isSupported() {
//            session = WCSession.default
//            session?.delegate = self
//            session?.activate()
//            print("iOS: WCSession activation requested")
//        } else {
//            print("iOS: WatchConnectivity is not supported on this device.")
//        }
//    }

    private func updateConnectionStatus() {
        DispatchQueue.main.async {
            self.isConnected = self.session?.isReachable ?? false
        }
    }
    
    private func checkConnectionStatus() {
        if let session = session {
            let isActive = session.activationState == .activated
//            let isCompanionAppInstalled = session.isCompanionAppInstalled
            
            DispatchQueue.main.async {
                self.isConnected = isActive //&& isCompanionAppInstalled
            }
            
            print("Watch: Connection status - Active: \(isActive), Companion App Installed: ---, Activation State: \(session.activationState.rawValue)")
        } else {
            DispatchQueue.main.async {
                self.isConnected = false
            }
            print("Watch: WCSession is not initialized")
        }
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
        DispatchQueue.main.async {
                   let wasConnected = self.isConnected
                   self.isConnected = session.isReachable
                   
                   // Trigger notification if disconnection occurs
                   if wasConnected && !session.isReachable {
                       self.showDisconnectionNotification = true
                   }
               }
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
