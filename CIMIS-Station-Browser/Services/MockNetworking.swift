//
//  MockNetworking.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Combine
import Foundation

struct MockNetworking {
    
    static func mockResponse<T: Decodable>(
        from filename: String,
        delay: TimeInterval = 0.0) -> AnyPublisher<T, Error>
    {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decodedData = try? JSONDecoder().decode(T.self, from: data) else {
            return Fail(error: ServiceError.invalidURL(message: "Invalid URL"))
                .eraseToAnyPublisher()
        }
        return Just(decodedData)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(delay), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}
