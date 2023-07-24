//
//  MockStationsService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Combine
import Foundation

class MockSuccessfulStationsService: FetchStationsServiceInterface {
    
    func fetchStations() -> AnyPublisher<StationsResponse, Error> {
        return MockNetworking.mockResponse(from: "all-stations")
    }
}

class MockFailureStationsService: FetchStationsServiceInterface {
    
    func fetchStations() -> AnyPublisher<StationsResponse, Error> {
        return Fail(
            error: URLError(.notConnectedToInternet)
        )
        .delay(for: .seconds(0.5), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
