//
//  ScannerApp.swift
//  Scanner
//
//  Created by Jack on 29/3/2021.
//

import SwiftUI

@main
struct ScannerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
