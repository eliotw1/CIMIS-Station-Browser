//
//  StationDetailsTests.swift
//  CIMIS-Station-BrowserTests
//
//  Created by Eliot Williams on 7/25/23.
//

@testable import CIMIS_Station_Browser
import XCTest
import Combine

class StationDetailsTests: XCTestCase {

    var viewModel: StationDetailsViewModel!
    var cancellables = Set<AnyCancellable>()
    var mockService: ServicesContainer!
    var testStore: SavedStationStore!
    
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
        let fetchService = MockFetchStationsService()
        let savedService = MockSavedStationService()
        mockService = ServicesContainer(fetchService: fetchService, savedService: savedService)
        testStore = SavedStationStore()
        viewModel = StationDetailsViewModel(
            station: testStation,
            savedStationsStore: testStore,
            stationsService: mockService.fetchStationsService,
            savedStationsService: mockService.savedStationsService
        )
    }
    
    override func tearDownWithError() throws {
        cancellables.removeAll()
        viewModel = nil
        mockService = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func testToggleSavedWhenNotSaved() throws {
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
            .$savedState
            .sink { state in
                switch state {
                case .loaded(let isSaved):
                    guard isSaved,
                        !isAddFavoriteFulfilled else { return }
                    addFavoriteExpectation.fulfill()
                    isAddFavoriteFulfilled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.toggleSaved()

        waitForExpectations(timeout: 5.0)
        XCTAssertTrue(testStore.savedStations.elementsEqual([testStation]))
    }
    
    func testToggleSavedWhenSaved() throws {
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
            .$savedState
            .sink { state in
                switch state {
                case .loaded(let isSaved):
                    guard isSaved,
                          !isAddFavoriteFulfilled else { return }
                    addFavoriteExpectation.fulfill()
                    isAddFavoriteFulfilled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        viewModel.toggleSaved()
        waitForExpectations(timeout: 5.0)
        XCTAssertTrue(testStore.savedStations.elementsEqual([testStation]))

        viewModel
            .$savedState
            .sink { state in
                switch state {
                case .loaded(let isSaved):
                    guard isSaved,
                          !isAddFavoriteFulfilled else { return }
                    addFavoriteExpectation.fulfill()
                    isAddFavoriteFulfilled = true
                default:
                    break
                }
            }
            .store(in: &cancellables)
        
        let removeFavoriteExpectation = expectation(description: "Remove favorite station")

        removeService.result = .success(true)
        getService.result = .success([])
        
        viewModel
            .$savedState
            .sink { state in
                switch state {
                case .loaded(let isSaved):
                    guard !isSaved else { return }
                    removeFavoriteExpectation.fulfill()
                default:
                    break
                }
            }
            .store(in: &cancellables)

        viewModel.toggleSaved()

        waitForExpectations(timeout: 5.0)
        XCTAssertTrue(testStore.savedStations.elementsEqual([]))
    }

    // TODO: test reportState handling when report API is available
}
