//
//  FetchSavedStationService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import CoreData

protocol FetchSavedStationServiceInterface {
    func fetchSaved() -> AnyPublisher<[Station], Error>
}

struct FetchSavedStationsService: FetchSavedStationServiceInterface {
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func fetchSaved() -> AnyPublisher<[Station], Error> {
        let fetchRequest = NSFetchRequest<StationEntity>(entityName: "StationEntity")
        return Future<[Station], Error> { promise in
            do {
                let fetchedResults = try self.viewContext.fetch(fetchRequest)
                let stations = fetchedResults.compactMap { $0.toStation() }
                promise(.success(stations))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
