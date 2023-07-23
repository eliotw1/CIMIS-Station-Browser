//
//  CIMISStationBrowserApp.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import SwiftUI

@main
struct CIMISStationBrowserApp: App {

    let persistenceController = PersistenceController.shared
    let servicesProvider = CIMISServices()
    
    var body: some Scene {
        WindowGroup {
            ContentView(services: servicesProvider)
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
    }
}
