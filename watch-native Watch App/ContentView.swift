import SwiftUI

struct ContentView: View {
    @EnvironmentObject var connectivityManager : WatchConnectivityManager

    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)

            Text(connectivityManager.isConnected ? "Watch is Connected" : "Watch is Disconnected")
                .padding()
                .foregroundColor(connectivityManager.isConnected ? .green : .red)
            
            Button("send Message") {
                connectivityManager.sendMessageToPhone(message: ["hello": "from Watch"])
            }
        
            
            Text("Hello, Ahmed!")
        }.onAppear {
            connectivityManager.scheduleBackgroundRefresh()
            connectivityManager.syncConnectionStatus()
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
