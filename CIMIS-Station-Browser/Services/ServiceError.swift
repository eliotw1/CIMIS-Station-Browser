//
//  ServiceError.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Foundation

enum ServiceError: Error {
    case invalidURL(message: String)
    case missingService(message: String)
}
