//
//  dual_n_backApp.swift
//  dual-n-back
//
//  Created by Saman Sathenjeri on 12/30/25.
//

import SwiftUI
import CoreData

@main
struct dual_n_backApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
