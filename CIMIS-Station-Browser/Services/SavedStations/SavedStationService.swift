//
//  SavedStationService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import CoreData
import Foundation

struct SavedStationService: SavedStationServiceInterface {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func getSaved() -> AnyPublisher<[Station], Error> {
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
    
    func add(station: Station) -> AnyPublisher<Bool, Error> {
        return Future<Bool, Error> { promise in
            let newFavorite = StationEntity(context: self.viewContext)
            newFavorite.update(with: station)
            
            do {
                try self.viewContext.save()
                promise(.success(true))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
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
                try self.viewContext.save()
                promise(.success(true))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
