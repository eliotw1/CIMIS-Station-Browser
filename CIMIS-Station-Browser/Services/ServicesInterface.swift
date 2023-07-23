//
//  ServicesInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Combine
import Foundation

enum APIError: Error {
    case invalidURL(message: String)
}

protocol StationsServiceInterface {
    func fetchStations() -> AnyPublisher<StationsResponse, Error>
}

protocol ServicesInterface {
    var stationService: StationsServiceInterface { get }
}

struct MockSuccessfulServices: ServicesInterface {
    var stationService: StationsServiceInterface = MockSuccessfulStationsService()
}
