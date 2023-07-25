//
//  FetchStationsServiceInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine

protocol FetchStationsServiceInterface {
    func fetchStations() -> AnyPublisher<StationsResponse, Error>
}
