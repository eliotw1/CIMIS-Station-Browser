//
//  SavedStationServiceInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import Foundation

protocol SavedStationServiceInterface {
    var getService: FetchSavedStationServiceInterface { get }
    var addService: AddSavedStationServiceInterface { get }
    var removeService: RemoveSavedStationServiceInterface { get }
}

protocol AddSavedStationServiceInterface {
    func add(station: Station) -> AnyPublisher<Bool, Error>
}

protocol RemoveSavedStationServiceInterface {
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error>
}
