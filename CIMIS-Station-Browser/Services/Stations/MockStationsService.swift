//
//  MockStationsService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Combine
import Foundation

class MockSuccessfulStationsService: StationsServiceInterface {
    
    func fetchStations() -> AnyPublisher<StationsResponse, Error> {
        return MockNetworking.mockResponse(from: "mock-stations")
    }
}

class MockFailureStationsService: StationsServiceInterface {
    
    func fetchStations() -> AnyPublisher<StationsResponse, Error> {
        return Fail(
            error: URLError(.notConnectedToInternet)
        )
        .delay(for: .seconds(0.5), scheduler: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
