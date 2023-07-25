//
//  MockStationsService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Combine
import Foundation

class MockFetchStationsService: FetchStationsServiceInterface {
    
    enum StubFile: String {
        case allStations
        case mockStations
    }
    
    var stubJSON: StubFile? = StubFile.allStations
    var error: Error = URLError(.cannotOpenFile)
    var delay: TimeInterval = 0.0
    
    func fetchStations() -> AnyPublisher<StationsResponse, Error> {
        if let fileName = stubJSON?.rawValue {
            return MockNetworking
                .mockResponse(from: fileName)
                .delay(for: .seconds(delay), scheduler: RunLoop.main)
                .eraseToAnyPublisher()
        } else {
            return Future { promise in
                promise(.failure(self.error))
            }
            .eraseToAnyPublisher()
        }
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
