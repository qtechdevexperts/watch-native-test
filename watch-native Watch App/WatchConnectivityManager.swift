import Foundation
import WatchConnectivity
import WatchKit

//MARK: Watch sending issue
class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    @Published var isConnected = false
    private var session: WCSession?
    private var backgroundRefreshInterval: TimeInterval = 1 * 60 // 1 minutes

    init(session:WCSession = .default) {
            self.session = session
            super.init()
            //        setupWatchConnectivity()
            session.delegate = self
            session.activate()
    }

//    func setupWatchConnectivity() {
//        session?.delegate = self
//        session?.activate()
////        if WCSession.isSupported() {
////            session = WCSession.default
////            session?.delegate = self
////            session?.activate()
////            print("Watch: WCSession activation requested")
////        } else {
////            print("Watch: WatchConnectivity is not supported on this device.")
////        }
//    }

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
        
//        print(message)
//        if let session = session, session.isReachable {
//            session.sendMessage(message, replyHandler: nil) { error in
//                print("iOS: Error sending message to watch: \(error.localizedDescription)")
//            }
//        } else {
//            print("iOS: Watch is not reachable")
//        }

        
        
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
    
    
    func session(_ session: WCSession, activationDidFailWith error: Error) {
            print("Activation failed with error: \(error.localizedDescription)")
        }

//        func sessionDidBecomeInactive(_ session: WCSession) {
//            print("Session became inactive.")
//        }
//
//        func sessionDidDeactivate(_ session: WCSession) {
//            print("Session deactivated.")
//            session.activate() // Re-activate session
//        }

        func sessionReachabilityDidChange(_ session: WCSession) {
            print("Session reachability changed: \(session.isReachable)")
        }
    // Handle incoming messages
//    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
//        print("Received message: \(message)")
//        
//        // Handle the message based on its content
//        if let messageType = message["type"] as? String {
//            // Perform actions based on the message type
//            print("Message type: \(messageType)")
//        }
//    }
    
    // Handle incoming messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        print("Received message: \(message)")
        
        // Handle the message based on its content
        if let messageType = message["type"] as? String {
            // Perform actions based on the message type
            print("Message type: \(messageType)")
        }
    }
    
}
