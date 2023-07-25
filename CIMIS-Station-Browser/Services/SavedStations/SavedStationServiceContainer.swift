//
//  SavedStationService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import CoreData
import Foundation

struct SavedStationServiceContainer: SavedStationServiceInterface {
    let getService: FetchSavedStationServiceInterface
    let addService: AddSavedStationServiceInterface
    let removeService: RemoveSavedStationServiceInterface
    
    init(
        getService: FetchSavedStationServiceInterface,
        addService: AddSavedStationServiceInterface,
        removeService: RemoveSavedStationServiceInterface)
    {
        self.getService = getService
        self.addService = addService
        self.removeService = removeService
    }
}
