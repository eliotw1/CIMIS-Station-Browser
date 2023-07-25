//
//  RemoveSavedStationService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import CoreData

protocol RemoveSavedStationServiceInterface {
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error>
}

struct RemoveSavedStationService: RemoveSavedStationServiceInterface {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func remove(stations: [Station]) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            let stationNumbers = stations.map { $0.number }
            let fetchRequest = NSFetchRequest<StationEntity>(entityName: "StationEntity")
            fetchRequest.predicate = NSPredicate(format: "number IN %@", stationNumbers)
            
            do {
                let fetchedResults = try self.viewContext.fetch(fetchRequest)
                for object in fetchedResults {
                    self.viewContext.delete(object)
                }
                promise(.success(true))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
