//
//  StationDataService.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import Combine
import Foundation

class StationDataService: StationDataServiceInterface {
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    func getData(
        for stationID: Int,
        startDate: Date = Date.yesterdayInPacificTime,
        endDate: Date = Date.yesterdayInPacificTime,
        appKey: String
    ) -> AnyPublisher<DataResponse, Error> {
        // Validate dates
        var startDateAdjusted = startDate
        var endDateAdjusted = endDate
        let yesterday = Date.yesterdayInPacificTime
        if endDate.timeIntervalSinceReferenceDate > Date.yesterdayInPacificTime.timeIntervalSinceReferenceDate {
            endDateAdjusted = yesterday
        }
        if startDate.timeIntervalSinceReferenceDate > endDateAdjusted.timeIntervalSinceReferenceDate {
            startDateAdjusted = yesterday
        }
        
        let start = dateFormatter.string(from: startDateAdjusted)
        let end = dateFormatter.string(from: endDateAdjusted)
        
        let urlString = "https://et.water.ca.gov/api/data?appKey=\(appKey)&targets=\(stationID)&startDate=\(start)&endDate=\(end)"
        
        guard let url = URL(string: urlString) else {
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


extension Date {
    static var yesterdayInPacificTime: Date {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(abbreviation: "PST")!
        return calendar.date(byAdding: .day, value: -1, to: Date())!
    }
}
