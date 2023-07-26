//
//  ServicesContainer.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Foundation

struct ServicesContainer: ServicesInterface {
    var fetchStationsService: FetchStationsServiceInterface
    var savedStationsService: SavedStationServiceInterface
    var stationDataService: StationDataServiceInterface
    
    init(
        fetchService: FetchStationsServiceInterface,
        savedService: SavedStationServiceInterface,
        stationDataService: StationDataServiceInterface
    ) {
        self.fetchStationsService = fetchService
        self.savedStationsService = savedService
        self.stationDataService = stationDataService
    }
}
