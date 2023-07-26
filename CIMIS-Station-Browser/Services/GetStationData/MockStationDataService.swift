//
//  MockStationDataService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import Combine
import Foundation

class MockStationDataService: StationDataServiceInterface {
    var result: Result<DataResponse, Error> = .success(
        DataResponse(data: DataResponse.DataClass(providers: []))
    )
    
    func getData(
        for stationID: Int,
        startDate: Date = Date.yesterdayInPacificTime,
        endDate: Date = Date.yesterdayInPacificTime,
        appKey: String
    ) -> AnyPublisher<DataResponse, Error> {
        return Future<DataResponse, Error> { promise in
            print("Mock Station Data Service Result: \(self.result)")
            promise(self.result)
        }
        .eraseToAnyPublisher()
    }
}
