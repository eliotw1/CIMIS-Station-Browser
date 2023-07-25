//
//  StationDetailsViewModel.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Foundation
import Combine

/// ViewModel class for Station Details which serves as an intermediary between the view and model,
/// and handles the business logic of the Station Details screen.
class StationDetailsViewModel: ObservableObject {
    
    /// Enum representing the state of the station being saved.
    enum SavedState {
        /// Indicates the station's saved state has been loaded.
        /// - Parameter saved: known saved state for the `Station`
        case loaded(saved: Bool)
        /// Indicates a request is in progress to toggle the saved state
        /// - Parameter saved: known saved state for the `Station`
        case updating(saved: Bool)
        /// Indicates the saved state of the station is being updated.
        /// - Parameter saved: known saved state for the `Station`
        /// - Parameter error: error from the `toggleSaved` call chain
        case error(saved: Bool, error: Error)  // Indicates there was an error while updating the saved state.

        /// Returns the current saved status of the station.
        var isSaved: Bool {
            switch self {
            case .loaded(let saved),
                    .updating(let saved),
                    .error(let saved, _):
                return saved
            }
        }
        
        /// Returns if the station's saved status is currently being updated.
        var isUpdating: Bool {
            guard case .updating = self else { return false }
            return true
        }
    }
    
    /// Enum representing the state of the station report.
    enum ReportState {
        case none
        case loaded
        case error
    }
    
    /// Current state of the station report.
    ///   TODO: Implement Report API:
    /// e.g. `curl http://et.water.ca.gov/api/data?appKey=YOUR-APP-KEY&targets=2,8,127&startDate=2023-01-01&endDate=2023-01-01`
    ///
    @Published private(set) var reportState: ReportState
    /// Current saved status of the station.
    @Published private(set) var savedState: SavedState
    /// Station details.
    @Published private(set) var station: Station
    
    /// Service to fetch station details.
    private let stationsService: FetchStationsServiceInterface
    /// Service to handle saved station operations.
    private let savedStationsService: SavedStationServiceInterface
    /// Store to handle saved stations after a fetch from CoreData.
    private let savedStationsStore: SavedStationStore
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Convenience var for the saved state of the `station`
    ///  Uses `savedStationsStore.savedStations`
    private var isSaved: Bool {
        savedStationsStore.savedStations.contains(station)
    }
    
    /// Initializes the ViewModel and configures observation of the `savedStationStore`
    /// - Parameter station: The Station to display
    /// - Parameter savedStationStore: A local store in which saved stations are placed after a fetch from core data
    /// - Parameter stationsService: `FetchStationsServiceInterface`
    /// - Parameter savedStationsService: `SavedStationServiceInterface`
    init(
        station: Station,
        savedStationsStore: SavedStationStore,
        stationsService: FetchStationsServiceInterface,
        savedStationsService: SavedStationServiceInterface
    ) {
        self.station = station
        self.reportState = .none
        self.savedStationsStore = savedStationsStore
        self.savedState = .loaded(
            saved: savedStationsStore
                .savedStations
                .contains(station)
        )
        self.stationsService = stationsService
        self.savedStationsService = savedStationsService
        
        configureObservations()
    }
    
    /// Observes changes in savedStations and updates the savedState to `.loaded` with the new values.
    func configureObservations() {
        savedStationsStore.savedStationsChanged.sink { [weak self] _ in
            guard let self = self else { return }
            self.savedState = .loaded(saved: self.isSaved)
        }.store(in: &cancellables)
    }
    
    /// Method to cancel all pending requests.
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: Saved Logic
extension StationDetailsViewModel {
    
    /// Toggles the saved status of the station.
    func toggleSaved() {
        if isSaved {
            removeFavorite()
        } else {
            addFavorite()
        }
    }
    
    /// Method to save the station as favorite.
    /// On Success, this inserts the station into the saved set
    /// On Error, this sets the savedState to `.error(saved: self.isSaved, error: error)`
    func addFavorite() {
        savedState = .updating(saved: true)
        savedStationsService.addService.add(station: station)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.savedState = .error(saved: self.isSaved, error: error)
                    }
                }
            }, receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.savedStationsStore.savedStations.insert(self.station)
                }
            })
            .store(in: &cancellables)
    }
    
    /// Method to remove the station from favorite.
    func removeFavorite() {
        savedState = .updating(saved: false)
        savedStationsService.removeService.remove(stations: [station])
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.savedState = .error(saved: self.isSaved, error: error)
                    }
                }
            }, receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.savedStationsStore.savedStations.remove(self.station)
                }
            })
            .store(in: &cancellables)
    }
}
