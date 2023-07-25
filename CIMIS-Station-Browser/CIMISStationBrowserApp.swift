//
//  CIMISStationBrowserApp.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import CoreData
import SwiftUI

@main
struct CIMISStationBrowserApp: App {
    
    let persistenceController = PersistenceController.shared
    let context: NSManagedObjectContext
    var services: ServicesInterface
    
    init() {
        let context = persistenceController.container.viewContext
        self.context = context
        services = ServicesContainer(
            fetchService: FetchStationsService(),
            savedService: SavedStationServiceContainer(
                getService: FetchSavedStationsService(context: context),
                addService: AddSavedStationService(context: context),
                removeService: RemoveSavedStationService(context: context)
            )
        )
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(services: services)
                .environment(
                    \.managedObjectContext,
                     persistenceController.container.viewContext
                )
        }
    }
}
