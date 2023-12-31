//
//  MockSavedStationsService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine

class MockFetchSavedStationService: FetchSavedStationServiceInterface {
    
    var result: Result<[Station], Error> = .success([]) {
        didSet {
            print("Set Mock Result: \(result)")
        }
    }
    
    func fetchSaved() -> AnyPublisher<[Station], Error> {
        return Future<[Station], Error> { promise in
            print("Mock Fetch Saved Result: \(self.result)")
            promise(self.result)
        }.eraseToAnyPublisher()
    }
}

class MockAddSavedStationService: AddSavedStationServiceInterface {
    var result: Result<Bool, Error> = .success(true)
    
    func add(station: Station) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            print("Mock Add Saved Result: \(self.result)")
            promise(self.result)
        }.eraseToAnyPublisher()
    }
}

class MockRemoveSavedStationService: RemoveSavedStationServiceInterface {
    var result: Result<Bool, Error> = .success(true)
    
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            print("Mock Remove Saved Result: \(self.result)")
            promise(self.result)
        }.eraseToAnyPublisher()
    }
}

class MockSavedStationService: SavedStationServiceInterface {
    var getService: FetchSavedStationServiceInterface = MockFetchSavedStationService()
    var addService: AddSavedStationServiceInterface = MockAddSavedStationService()
    var removeService: RemoveSavedStationServiceInterface = MockRemoveSavedStationService()
}
