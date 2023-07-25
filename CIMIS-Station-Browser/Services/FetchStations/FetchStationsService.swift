//
//  FetchStationsService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Combine
import Foundation

class FetchStationsService: FetchStationsServiceInterface {
    
    private static let urlString = "https://et.water.ca.gov/api/station"
    
    func fetchStations() -> AnyPublisher<StationsResponse, Error> {
        guard let url = URL(string: FetchStationsService.urlString) else {
            return Fail(
                error: ServiceError.invalidURL(
                    message: "Invalid URL"
                )
            )
            .eraseToAnyPublisher()
        }
        
        return Networking.fetch(url: url)
    }
}
