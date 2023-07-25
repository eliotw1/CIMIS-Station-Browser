//
//  SavedStationStore.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine

class SavedStationStore: ObservableObject {
    
    var savedStationsChanged = PassthroughSubject<Void, Never>()
    var savedStations = Set<Station>() {
        didSet {
            savedStationsChanged.send(())
        }
    }
}
