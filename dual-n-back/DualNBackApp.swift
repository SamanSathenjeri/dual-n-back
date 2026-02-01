//
//  DualNBackApp.swift
//  DualNBack
//
//

import SwiftUI

@main
struct DualNBackApp: App {
    init() {
        // Request notification permissions on app launch
        NotificationManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

