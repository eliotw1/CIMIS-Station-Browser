//
//  SavedStationServiceInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine

protocol SavedStationServiceInterface:
    GetSavedStationServiceInterface,
    AddSavedStationServiceInterface,
    RemoveSavedStationServiceInterface {}

protocol GetSavedStationServiceInterface {
    func getSaved() -> AnyPublisher<[Station], Error>
}

protocol AddSavedStationServiceInterface {
    func add(station: Station) -> AnyPublisher<Bool, Error>
}

protocol RemoveSavedStationServiceInterface {
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error>
}
