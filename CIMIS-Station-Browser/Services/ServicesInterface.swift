//
//  ServicesInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Foundation

protocol ServicesInterface {
    var fetchStationsService: FetchStationsServiceInterface { get }
    var savedStationsService: SavedStationServiceInterface { get }
    var stationDataService: StationDataServiceInterface { get }
}
