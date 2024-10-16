//
//  watch_nativeApp.swift
//  watch-native Watch App
//
//  Created by Hassan Wajih on 16/10/2024.
//

import SwiftUI
import WatchKit



@main
struct watch_native_Watch_App: App {
    @StateObject private var connectivityManager = WatchConnectivityManager()
     
     var body: some Scene {
         WindowGroup {
             ContentView()
                 .environmentObject(connectivityManager)
         }
         .backgroundTask(.appRefresh("connectivityRefresh")) { _ in
            await connectivityManager.performBackgroundRefresh()
         }
     }
}
