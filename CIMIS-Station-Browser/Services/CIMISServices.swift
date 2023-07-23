//
//  CIMISServices.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Foundation

struct CIMISServices: ServicesInterface {
    var stationService: StationsServiceInterface = CIMISStationsService()
}
