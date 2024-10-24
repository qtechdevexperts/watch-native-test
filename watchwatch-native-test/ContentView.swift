import SwiftUI
import WatchConnectivity

struct ContentView: View {
    
    @EnvironmentObject var watchConnectivityManager: iOSWatchConnectivityManager
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text(watchConnectivityManager.isConnected ? "Watch is Connected" : "Watch is Disconnected")
                .padding()
                .foregroundColor(watchConnectivityManager.isConnected ? .green : .red)
            
//            Button("Send Message") {
//                watchConnectivityManager.sendMessageToWatch(message: ["message": "chala gya message mobile se ihone pr"])
//            }
            
            Text("Hello, Jason!")
        }
        .padding()
        .onChange(of: watchConnectivityManager.showDisconnectionNotification) { newValue in
            if newValue {
                showAlert = true
                watchConnectivityManager.showDisconnectionNotification = false // Reset notification flag
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
}

#Preview {
    ContentView()
        .environmentObject(iOSWatchConnectivityManager()) // Inject the manager
}
