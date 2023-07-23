//
//  ContentView.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    private var services: ServicesInterface
    
    init(services: ServicesInterface) {
        self.services = services
    }
    
    var body: some View {
        StationListView(stationsProvider: services.stationService)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(services: MockSuccessfulServices()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
