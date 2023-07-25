//
//  SavedStationStore.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine

/// A Data Store for Saved Stations
/// - Parameter savedStationsChanged: A `PassthroughSubject<Void, Never>` to observe changes to the store.
/// - Parameter savedStations: A set of saved `Station` models to be observed.
class SavedStationStore: ObservableObject {
    
    var savedStationsChanged = PassthroughSubject<Void, Never>()
    var savedStations = Set<Station>() {
        didSet {
            savedStationsChanged.send(())
        }
    }
}
