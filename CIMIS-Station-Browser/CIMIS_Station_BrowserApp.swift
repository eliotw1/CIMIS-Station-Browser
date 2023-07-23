//
//  CIMIS_Station_BrowserApp.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import SwiftUI

@main
struct CIMIS_Station_BrowserApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
