//
//  ContentView.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import SwiftUI

struct ContentView: View {
    
    private var services: ServicesInterface
    
    init(services: ServicesInterface) {
        self.services = services
    }
    
    var body: some View {
        StationListView(
            stationsService: services.fetchStationsService,
            savedStationsService: services.savedStationsService
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(
            services: ServicesContainer(
                fetchService: MockSuccessfulStationsService(),
                savedService: SavedStationService(
                    context: PersistenceController.preview.container.viewContext
                )
            )
        )
        .environment(
            \.managedObjectContext,
             PersistenceController.preview.container.viewContext
        )
    }
}
