import SwiftUI
import WatchConnectivity
import UserNotifications

struct ContentView: View {
    
    @EnvironmentObject var watchConnectivityManager: iOSWatchConnectivityManager
    @State private var showAlert = false
    @State private var notificationsEnabled = false // Track notification permission state

    init(){
        requestNotificationPermission()
    }
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text(watchConnectivityManager.isConnected ? "Watch is Connected" : "Watch is Disconnected")
                .padding()
                .foregroundColor(watchConnectivityManager.isConnected ? .green : .red)
            
            Text("Hello, Jason!")
            
        }
        .padding()
        .onAppear {
            checkNotificationStatus()
        }
        .onChange(of: watchConnectivityManager.showDisconnectionNotification) { newValue in
            if newValue {
                showAlert = true
                watchConnectivityManager.showDisconnectionNotification = false // Reset notification flag
                triggerLocalNotification()
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Watch Disconnected"),
                message: Text("The Apple Watch has disconnected."),
                dismissButton: .default(Text("OK"))
            )
        }
    }
    
    // Check current notification settings
    func checkNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus == .authorized {
                    notificationsEnabled = true
                } else {
                    notificationsEnabled = false
                }
            }
        }
    }
    
    // Request notification permission
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    notificationsEnabled = true
                    print("Notification permission granted")
                } else {
                    print("Notification permission denied")
                }
                if let error = error {
                    print("Error requesting notification permission: \(error)")
                }
            }
        }
    }
    
    // Trigger local notification
    func triggerLocalNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Watch Disconnected"
        content.body = "The Apple Watch has disconnected from your iPhone."
        content.sound = .default
        
        // Create a trigger to send the notification immediately
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        // Create the request
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        // Add the notification request to the system
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(iOSWatchConnectivityManager()) // Inject the manager
}
