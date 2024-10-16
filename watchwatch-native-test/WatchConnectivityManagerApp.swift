import WatchConnectivity

class WatchConnectivityManager: NSObject, WCSessionDelegate, ObservableObject {
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("inActive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        setupWatchConnectivity()
    }
    
   
    
    @Published var isConnected = false

    override init() {
        super.init()
        setupWatchConnectivity()
    }

    func setupWatchConnectivity() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
            print("WCSession activation requested")
        } else {
            print("WatchConnectivity is not supported on this device.")
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        print("Watch connection status changed: Paired: \(session.isReachable), Reachable: \(session.isReachable)")
        DispatchQueue.main.async {
            self.isConnected = session.isReachable
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("WCSession activated with state: \(activationState.rawValue)")
        print("Is paired: \(session.isReachable), Is companion app installed: \(session.isComplicationEnabled), Is reachable: \(session.isReachable)")
    }
}
