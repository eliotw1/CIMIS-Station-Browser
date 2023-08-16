//
//  ServiceContainerTests.swift
//  CIMIS-Station-BrowserTests
//
//  Created by Eliot Williams on 7/24/23.
//

import Combine
import XCTest
@testable import CIMIS_Station_Browser

class ServiceContainerTests: XCTestCase {
    
    var servicesContainer: ServicesContainer!
    var cancellables: Set<AnyCancellable>!
    
    let testStation = Station(
        number: "123",
        name: "Test Station",
        city: "Test City",
        isActive: true,
        isEtoStation: false,
        elevation: 100,
        groundCover: "Test Ground",
        hmsLatitude: "12.34",
        hmsLongitude: "56.78",
        sitingDesc: "Test Desc",
        zipCodes: ["10000", "20000"]
    )
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        let fetchService = MockFetchStationsService()
        let savedService = MockSavedStationService()
        let dataService = MockStationDataService()
        servicesContainer = ServicesContainer(
            fetchService: fetchService,
            savedService: savedService,
            stationDataService: dataService
        )
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        servicesContainer = nil
        cancellables = nil
        try super.tearDownWithError()
    }
    
    func testFetchMockStationsService() {
        guard let mockFetchService = servicesContainer.fetchStationsService as? MockFetchStationsService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        mockFetchService.error = URLError(.badURL)
        mockFetchService.stubJSON = .mockStations
        
        let fetchStationsExpectation = expectation(description: "Fetch stations")
        servicesContainer.fetchStationsService.fetchStations().sink { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Fetch stations failed with error: \(error)")
            case .finished:
                fetchStationsExpectation.fulfill()
            }
        } receiveValue: { response in
            XCTAssertEqual(response.stations.count, 1)
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testFetchAllStationsService() {
        guard let fetchService = servicesContainer.fetchStationsService as? MockFetchStationsService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        fetchService.error = URLError(.badURL)
        fetchService.stubJSON = .allStations
        
        let fetchStationsExpectation = expectation(description: "Fetch stations")
        servicesContainer.fetchStationsService.fetchStations().sink { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Fetch stations failed with error: \(error)")
            case .finished:
                fetchStationsExpectation.fulfill()
            }
        } receiveValue: { response in
            XCTAssertEqual(response.stations.count, 267)
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSavedStationsServiceGet() {
        guard let savedService = servicesContainer.savedStationsService as? MockSavedStationService,
              let getService = savedService.getService as? MockFetchSavedStationService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        getService.result = .success([Station]())
        
        let getSavedExpectation = expectation(description: "Get saved stations")
        servicesContainer.savedStationsService.getService.fetchSaved().sink { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Get saved stations failed with error: \(error)")
            case .finished:
                getSavedExpectation.fulfill()
            }
        } receiveValue: { stations in
            XCTAssertTrue(stations.isEmpty)
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSavedStationsServiceAdd() {
        guard let savedService = servicesContainer.savedStationsService as? MockSavedStationService,
              let addService = savedService.addService as? MockAddSavedStationService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        addService.result = .success(true)
        
        let addStationExpectation = expectation(description: "Add station")
        servicesContainer.savedStationsService.addService.add(station: testStation).sink { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Add station failed with error: \(error)")
            case .finished:
                addStationExpectation.fulfill()
            }
        } receiveValue: { success in
            XCTAssertTrue(success)
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
    
    func testSavedStationsServiceRemove() {
        guard let savedService = servicesContainer.savedStationsService as? MockSavedStationService,
              let removeService = savedService.removeService as? MockRemoveSavedStationService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        removeService.result = .success(true)
        
        let removeStationsExpectation = expectation(description: "Remove stations")
        servicesContainer.savedStationsService.removeService.remove(stations: [testStation]).sink { completion in
            switch completion {
            case .failure(let error):
                XCTFail("Remove stations failed with error: \(error)")
            case .finished:
                removeStationsExpectation.fulfill()
            }
        } receiveValue: { success in
            XCTAssertTrue(success)
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1, handler: nil)
    }
}
