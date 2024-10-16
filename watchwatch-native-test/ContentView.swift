//
//  ContentView.swift
//  watchwatch-native-test
//
//  Created by Hassan Wajih on 16/10/2024.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    
    @EnvironmentObject var watchConnectivityManager: iOSWatchConnectivityManager
        
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            
            Text(watchConnectivityManager.isConnected ? "Watch is Connected" : "Watch is Disconnected")
                .padding()
                .foregroundColor(watchConnectivityManager.isConnected ? .green : .red)
            
            
            Button("Send Message") {
                watchConnectivityManager.sendMessageToWatch(message: ["message": "connect?"])
            }
            
            
            Text("Hello, Subhan!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
