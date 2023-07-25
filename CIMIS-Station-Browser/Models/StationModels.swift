//
//  Models.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Foundation

struct StationsResponse: Codable {
    let stations: [Station]
    
    enum CodingKeys: String, CodingKey {
        case stations = "Stations"
    }
    
    init(stations: [Station]) {
        self.stations = stations
    }
}

struct Station: Codable, Hashable {
    
    enum CodingKeys: String, CodingKey {
        case number = "StationNbr"
        case name = "Name"
        case city = "City"
        case isActive = "IsActive"
        case isEtoStation = "IsEtoStation"
        case elevation = "Elevation"
        case groundCover = "GroundCover"
        case hmsLatitude = "HmsLatitude"
        case hmsLongitude = "HmsLongitude"
        case sitingDesc = "SitingDesc"
        case zipCodes = "ZipCodes"
    }
    
    let number: String
    let name: String
    let city: String
    let isActive: Bool
    let isEtoStation: Bool
    let elevation: Int
    let groundCover: String
    let hmsLatitude: String
    let hmsLongitude: String
    let sitingDesc: String
    let zipCodes: [String]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        guard let number = try? container.decode(String.self, forKey: .number),
              let name = try? container.decode(String.self, forKey: .name),
              let city = try? container.decode(String.self, forKey: .city),
              let isActiveString = try? container.decode(String.self, forKey: .isActive),
              let isEtoStationString = try? container.decode(String.self, forKey: .isEtoStation),
              let elevationString = try? container.decode(String.self, forKey: .elevation),
              let groundCover = try? container.decode(String.self, forKey: .groundCover),
              let hmsLatitude = try? container.decode(String.self, forKey: .hmsLatitude),
              let hmsLongitude = try? container.decode(String.self, forKey: .hmsLongitude),
              let sitingDesc = try? container.decode(String.self, forKey: .sitingDesc),
              let zipCodes = try? container.decode([String].self, forKey: .zipCodes)
        else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Incomplete data"))
        }
        
        self.number = number
        self.name = name
        self.city = city
        self.isActive = isActiveString.lowercased() == "true"
        self.isEtoStation = isEtoStationString.lowercased() == "true"
        self.elevation = Int(elevationString) ?? 0
        self.groundCover = groundCover
        self.hmsLatitude = hmsLatitude
        self.hmsLongitude = hmsLongitude
        self.sitingDesc = sitingDesc
        self.zipCodes = zipCodes
    }
    
    init(
        number: String,
        name: String,
        city: String,
        isActive: Bool,
        isEtoStation: Bool,
        elevation: Int,
        groundCover: String,
        hmsLatitude: String,
        hmsLongitude: String,
        sitingDesc: String,
        zipCodes: [String]
    ) {
        self.number = number
        self.name = name
        self.city = city
        self.isActive = isActive
        self.isEtoStation = isEtoStation
        self.elevation = elevation
        self.groundCover = groundCover
        self.hmsLatitude = hmsLatitude
        self.hmsLongitude = hmsLongitude
        self.sitingDesc = sitingDesc
        self.zipCodes = zipCodes
    }
}
