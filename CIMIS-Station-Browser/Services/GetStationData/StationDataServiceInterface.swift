//
//  StationDataServiceInterface.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import Combine
import Foundation

protocol StationDataServiceInterface {
    func getData(
        for stationID: Int,
        startDate: Date,
        endDate: Date,
        appKey: String
    ) -> AnyPublisher<DataResponse, Error>
}
