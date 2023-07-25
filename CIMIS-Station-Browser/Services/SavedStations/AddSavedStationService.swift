//
//  AddSavedStationService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import CoreData

protocol AddSavedStationServiceInterface {
    func add(station: Station) -> AnyPublisher<Bool, Error>
}

struct AddSavedStationService: AddSavedStationServiceInterface {
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
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
}
