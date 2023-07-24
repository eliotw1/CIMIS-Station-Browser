//
//  MockSavedStationService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import Foundation

class MockSavedStationService: SavedStationServiceInterface {
    
    var mockSavedStations: [Station]
    
    init(stations: [Station] = []) {
        self.mockSavedStations = stations
    }
    
    func getSaved() -> AnyPublisher<[Station], Error> {
        return Future<[Station], Error> { promise in
            promise(.success(self.mockSavedStations))
        }.eraseToAnyPublisher()
    }
    
    func add(station: Station) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            self.mockSavedStations.append(station)
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
    
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            stations.forEach { station in
                if let index = self.mockSavedStations.firstIndex(where: { $0.number == station.number }) {
                    self.mockSavedStations.remove(at: index)
                }
            }
            promise(.success(true))
        }.eraseToAnyPublisher()
    }
}

enum MockCoreDataErrors: Error {
    case fetchFailed
    case addFailed
    case removeFailed
}

class MockFailingSavedStationService: SavedStationServiceInterface {
    
    func getSaved() -> AnyPublisher<[Station], Error> {
        return Future<[Station], Error> { promise in
            promise(.failure(MockCoreDataErrors.fetchFailed))
        }.eraseToAnyPublisher()
    }
    
    func add(station: Station) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            promise(.failure(MockCoreDataErrors.addFailed))
        }.eraseToAnyPublisher()
    }
    
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            promise(.failure(MockCoreDataErrors.removeFailed))
        }.eraseToAnyPublisher()
    }
}
