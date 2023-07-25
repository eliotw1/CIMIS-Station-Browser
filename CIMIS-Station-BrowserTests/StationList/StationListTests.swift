//
//  StationListTests.swift
//  CIMIS-Station-BrowserTests
//
//  Created by Eliot Williams on 7/25/23.
//

@testable import CIMIS_Station_Browser
import XCTest
import Combine

class StationListTests: XCTestCase {
    
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

    var cancellables = Set<AnyCancellable>()
    var mockService: ServicesContainer!
    var testStore: SavedStationStore!
    var viewModel: StationListViewModel!
    
    override func setUpWithError() throws {
        let fetchService = MockFetchStationsService()
        let savedService = MockSavedStationService()
        mockService = ServicesContainer(fetchService: fetchService, savedService: savedService)
        testStore = SavedStationStore()
        viewModel = StationListViewModel(
            stationsService: mockService.fetchStationsService,
            savedStationsService: mockService.savedStationsService,
            savedStationsStore: testStore
        )
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
        viewModel = nil
        mockService = nil
        testStore = nil
        try super.tearDownWithError()
    }
    
    func testFetchStationsSuccessful() throws {
        guard let fetchService = mockService.fetchStationsService as? MockFetchStationsService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        fetchService.stubJSON = .mockStations

        let fetchExpectation = expectation(description: "Fetch stations")
        
        viewModel.$stationsState
            .sink { state in
                switch state {
                case .loaded(let stations):
                    XCTAssertEqual(stations.count, 1)
                    fetchExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.getAllStations()
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testFetchStationsFailure() throws {
        guard let fetchService = mockService.fetchStationsService as? MockFetchStationsService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        let testError = URLError(.badURL)
        fetchService.error = testError
        fetchService.stubJSON = nil
        let errorExpectation = expectation(description: "Fetch stations error")
        
        viewModel.$stationsState
            .sink { state in
                switch state {
                case .error(_, let error):
                    XCTAssertEqual(error as? URLError, testError)
                    errorExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.getAllStations()
        
        waitForExpectations(timeout: 5.0)
    }
    
    func testAddFavoriteStation() throws {
        guard let savedService = mockService.savedStationsService as? MockSavedStationService,
              let addService = savedService.addService as? MockAddSavedStationService,
              let getService = savedService.getService as? MockFetchSavedStationService else {
            assertionFailure("Mock Services Not Configured")
            return
        }
        addService.result = .success(true)
        getService.result = .success([testStation])
        
        let addFavoriteExpectation = expectation(description: "Add favorite station")
        var isAddFavoriteFulfilled = false

        viewModel
            .$savedStationsState
            .sink { state in
                switch state {
                case .loaded(let stations):
                    guard stations.count > 0,
                          !isAddFavoriteFulfilled else { return }
                    addFavoriteExpectation.fulfill()
                    isAddFavoriteFulfilled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.toggleSaved(testStation)

        waitForExpectations(timeout: 5.0)
        XCTAssertTrue(viewModel.isSaved(testStation))
    }
    
    func testRemoveFavoriteStation() throws {
        guard let savedService = mockService.savedStationsService as? MockSavedStationService,
              let addService = savedService.addService as? MockAddSavedStationService,
              let removeService = savedService.removeService as? MockRemoveSavedStationService,
              let getService = savedService.getService as? MockFetchSavedStationService else
        {
            assertionFailure("Mock Services Not Configured")
            return
        }
        
        addService.result = .success(true)
        getService.result = .success([testStation])
        
        let addFavoriteExpectation = expectation(description: "Add favorite station")
        var isAddFavoriteFulfilled = false
        
        viewModel
            .$savedStationsState
            .sink { state in
                switch state {
                case .loaded(let stations):
                    guard stations.count > 0,
                          !isAddFavoriteFulfilled else { return }
                    addFavoriteExpectation.fulfill()
                    isAddFavoriteFulfilled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.getSavedStations()
        waitForExpectations(timeout: 5.0)
        XCTAssertTrue(viewModel.isSaved(testStation))

        viewModel
            .$savedStationsState
            .sink { state in
                switch state {
                case .loaded(let stations):
                    guard stations.count > 0,
                          !isAddFavoriteFulfilled else { return }
                    addFavoriteExpectation.fulfill()
                    isAddFavoriteFulfilled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        removeService.result = .success(true)
        let removeFavoriteExpectation = expectation(description: "Remove favorite station")

        removeService.result = .success(true)
        getService.result = .success([])
        
        viewModel
            .$savedStationsState
            .sink { state in
                switch state {
                case .loaded(let stations):
                    guard stations.count == 0 else { return }
                    removeFavoriteExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.toggleSaved(testStation)

        waitForExpectations(timeout: 5.0)
        XCTAssertFalse(viewModel.isSaved(testStation))
    }

    func testPerformanceExample() throws {
        self.measure {
            viewModel.getAllStations()
        }
    }
}
