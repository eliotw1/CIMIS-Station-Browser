//
//  DataModels.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import Foundation

struct StationDailyDataReport {
    let date: String
    let values: [NamedValue]
    
    struct NamedValue {
        let title: String
        let value: String
        let qc: String
        let unit: String
    }
    
    init(
        from record: DataResponse.DataClass.Provider.Record
    ) {
        self.date = record.date
        var valuesArray: [NamedValue] = []
        valuesArray.append(NamedValue(title: "Air Temperature Average", value: record.dayAirTmpAvg.value, qc: record.dayAirTmpAvg.qc, unit: record.dayAirTmpAvg.unit))
        valuesArray.append(NamedValue(title: "Air Temperature Max", value: record.dayAirTmpMax.value, qc: record.dayAirTmpMax.qc, unit: record.dayAirTmpMax.unit))
        valuesArray.append(NamedValue(title: "Air Temperature Min", value: record.dayAirTmpMin.value, qc: record.dayAirTmpMin.qc, unit: record.dayAirTmpMin.unit))
        valuesArray.append(NamedValue(title: "Dew Point", value: record.dayDewPnt.value, qc: record.dayDewPnt.qc, unit: record.dayDewPnt.unit))
        valuesArray.append(NamedValue(title: "Evapotranspiration (Eto)", value: record.dayAsceEto.value, qc: record.dayAsceEto.qc, unit: record.dayAsceEto.unit))
        valuesArray.append(NamedValue(title: "Precipitation", value: record.dayPrecip.value, qc: record.dayPrecip.qc, unit: record.dayPrecip.unit))
        valuesArray.append(NamedValue(title: "Relative Humidity Average", value: record.dayRelHumAvg.value, qc: record.dayRelHumAvg.qc, unit: record.dayRelHumAvg.unit))
        valuesArray.append(NamedValue(title: "Relative Humidity Max", value: record.dayRelHumMax.value, qc: record.dayRelHumMax.qc, unit: record.dayRelHumMax.unit))
        valuesArray.append(NamedValue(title: "Relative Humidity Min", value: record.dayRelHumMin.value, qc: record.dayRelHumMin.qc, unit: record.dayRelHumMin.unit))
        valuesArray.append(NamedValue(title: "Soil Temperature Average", value: record.daySoilTmpAvg.value, qc: record.daySoilTmpAvg.qc, unit: record.daySoilTmpAvg.unit))
        valuesArray.append(NamedValue(title: "Solar Radiation Average", value: record.daySolRadAvg.value, qc: record.daySolRadAvg.qc, unit: record.daySolRadAvg.unit))
        valuesArray.append(NamedValue(title: "Vapor Pressure Average", value: record.dayVapPresAvg.value, qc: record.dayVapPresAvg.qc, unit: record.dayVapPresAvg.unit))
        valuesArray.append(NamedValue(title: "Wind Run", value: record.dayWindRun.value, qc: record.dayWindRun.qc, unit: record.dayWindRun.unit))
        valuesArray.append(NamedValue(title: "Wind Speed Average", value: record.dayWindSpdAvg.value, qc: record.dayWindSpdAvg.qc, unit: record.dayWindSpdAvg.unit))
        self.values = valuesArray
    }
}

struct DataResponse: Codable {
    let data: DataClass
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
    
    struct DataClass: Codable {
        let providers: [Provider]
        
        enum CodingKeys: String, CodingKey {
            case providers = "Providers"
        }
        
        init(providers: [Provider]) {
            self.providers = providers
        }
        
        struct Provider: Codable {
            let name: String
            let type: String
            let owner: String
            let records: [Record]
            
            enum CodingKeys: String, CodingKey {
                case name = "Name"
                case type = "Type"
                case owner = "Owner"
                case records = "Records"
            }
            
            init(name: String, type: String, owner: String, records: [Record]) {
                self.name = name
                self.type = type
                self.owner = owner
                self.records = records
            }
            
            struct Record: Codable {
                let date: String
                let station: String
                let zipCodes: String
                let dayAirTmpAvg: Value
                let dayAirTmpMax: Value
                let dayAirTmpMin: Value
                let dayDewPnt: Value
                let dayAsceEto: Value
                let dayPrecip: Value
                let dayRelHumAvg: Value
                let dayRelHumMax: Value
                let dayRelHumMin: Value
                let daySoilTmpAvg: Value
                let daySolRadAvg: Value
                let dayVapPresAvg: Value
                let dayWindRun: Value
                let dayWindSpdAvg: Value
                
                enum CodingKeys: String, CodingKey {
                    case date = "Date"
                    case station = "Station"
                    case zipCodes = "ZipCodes"
                    case dayAirTmpAvg = "DayAirTmpAvg"
                    case dayAirTmpMax = "DayAirTmpMax"
                    case dayAirTmpMin = "DayAirTmpMin"
                    case dayDewPnt = "DayDewPnt"
                    case dayAsceEto = "DayAsceEto"
                    case dayPrecip = "DayPrecip"
                    case dayRelHumAvg = "DayRelHumAvg"
                    case dayRelHumMax = "DayRelHumMax"
                    case dayRelHumMin = "DayRelHumMin"
                    case daySoilTmpAvg = "DaySoilTmpAvg"
                    case daySolRadAvg = "DaySolRadAvg"
                    case dayVapPresAvg = "DayVapPresAvg"
                    case dayWindRun = "DayWindRun"
                    case dayWindSpdAvg = "DayWindSpdAvg"
                }
                
                init(
                    date: String,
                    station: String,
                    zipCodes: String,
                    dayAirTmpAvg: Value,
                    dayAirTmpMax: Value,
                    dayAirTmpMin: Value,
                    dayDewPnt: Value,
                    dayAsceEto: Value,
                    dayPrecip: Value,
                    dayRelHumAvg: Value,
                    dayRelHumMax: Value,
                    dayRelHumMin: Value,
                    daySoilTmpAvg: Value,
                    daySolRadAvg: Value,
                    dayVapPresAvg: Value,
                    dayWindRun: Value,
                    dayWindSpdAvg: Value
                ) {
                    self.date = date
                    self.station = station
                    self.zipCodes = zipCodes
                    self.dayAirTmpAvg = dayAirTmpAvg
                    self.dayAirTmpMax = dayAirTmpMax
                    self.dayAirTmpMin = dayAirTmpMin
                    self.dayDewPnt = dayDewPnt
                    self.dayAsceEto = dayAsceEto
                    self.dayPrecip = dayPrecip
                    self.dayRelHumAvg = dayRelHumAvg
                    self.dayRelHumMax = dayRelHumMax
                    self.dayRelHumMin = dayRelHumMin
                    self.daySoilTmpAvg = daySoilTmpAvg
                    self.daySolRadAvg = daySolRadAvg
                    self.dayVapPresAvg = dayVapPresAvg
                    self.dayWindRun = dayWindRun
                    self.dayWindSpdAvg = dayWindSpdAvg
                }

                
                struct Value: Codable {
                    let value: String
                    let qc: String
                    let unit: String
                    
                    enum CodingKeys: String, CodingKey {
                        case value = "Value"
                        case qc = "Qc"
                        case unit = "Unit"
                    }
                    
                    init(value: String, qc: String, unit: String) {
                        self.value = value
                        self.qc = qc
                        self.unit = unit
                    }
                }
            }
        }
    }
}
