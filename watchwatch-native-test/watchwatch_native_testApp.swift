//
//  watchwatch_native_testApp.swift
//  watchwatch-native-test
//
//  Created by Hassan Wajih on 16/10/2024.
//

import SwiftUI

@main
struct watchwatch_native_testApp: App {
    @StateObject private var watchConnectivityManager = iOSWatchConnectivityManager()
        
        var body: some Scene {
            WindowGroup {
                ContentView()
                    .environmentObject(watchConnectivityManager)
            }
        }
}
