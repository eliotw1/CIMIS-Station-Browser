//
//  SavedStationServiceInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Foundation

protocol SavedStationServiceInterface {
    var getService: FetchSavedStationServiceInterface { get }
    var addService: AddSavedStationServiceInterface { get }
    var removeService: RemoveSavedStationServiceInterface { get }
}
