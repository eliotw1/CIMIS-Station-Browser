//
//  StationListViewModel.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Foundation
import Combine

/// `StationListViewModel` is the Observable object that acts as an intermediary between
/// the view and model for the Station List. It handles all business logic related to the station list.
class StationListViewModel: ObservableObject {
    
    /// An enumeration representing the possible states of the stations service.
    enum StationsServiceState {
        case initial  /// The initial state of the service, before any actions have been performed.
        case loading  /// The state during the process of loading stations.
        case loaded([Station])  /// The state after successfully loading stations.
        case error([Station], Error)  /// The state when an error occurs while loading stations.
    }
    
    /// An enumeration representing the possible states of the saved stations.
    enum SavedStationsState {
        case initial  /// The initial state of the saved stations, before any actions have been performed.
        case updating([Station])  /// The state during the process of updating saved stations.
        case loaded([Station])  /// The state after successfully loading saved stations.
        case error([Station], Error)  /// The state when an error occurs while loading saved stations.
        
        /// Returns the list of currently saved stations.
        var savedStations: [Station] {
            switch self {
            case .initial:
                return []
            case .updating(let array),
                 .loaded(let array),
                 .error(let array, _):
                return array
            }
        }
    }
    
    /// The currently active station.
    @Published var activeStation: Station? = nil
    /// The current state of the saved stations.
    @Published private(set) var savedStationsState = SavedStationsState.initial
    /// The current state of the stations service.
    @Published private(set) var stationsState = StationsServiceState.initial
    
    private let savedStationsStore: SavedStationStore
    
    /// The list of saved stations.
    private var savedStations: [Station] {
        Array(savedStationsStore.savedStations)
    }
    
    private var allStations = [Station]()
    
    /// The list of currently active stations.
    private var activeStations: [Station] {
        allStations.filter { $0.isActive }
    }
    
    private let savedStationsService: SavedStationServiceInterface
    private let stationsService: FetchStationsServiceInterface
    private var cancellables = Set<AnyCancellable>()
    
    /// Initializes the ViewModel and starts observing changes in the saved stations store.
    /// - Parameters:
    ///   - stationsService: The service to fetch station data.
    ///   - savedStationsService: The service to handle saved station operations.
    ///   - savedStationsStore: The store to handle saved stations.
    init(
        stationsService: FetchStationsServiceInterface,
        savedStationsService: SavedStationServiceInterface,
        savedStationsStore: SavedStationStore
    ) {
        self.savedStationsStore = savedStationsStore
        self.stationsService = stationsService
        self.savedStationsService = savedStationsService
        
        savedStationsStore.savedStationsChanged.sink { [weak self] _ in
            guard let self = self else { return }
            self.savedStationsState = .loaded(self.savedStations)
        }.store(in: &cancellables)
        getSavedStations()
    }
    
    /// Cancels all pending requests.
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: Station Details
extension StationListViewModel {
    /// Checks if a station is saved.
    /// - Parameter station: The station to check.
    /// - Returns: A boolean indicating whether the station is saved.
    func isSaved(_ station: Station) -> Bool {
        savedStations.contains(where: { $0.number == station.number })
    }
    
    /// Toggles the saved status of a station.
    /// - Parameter station: The station whose saved status to toggle.
    func toggleSaved(_ station: Station) {
        if isSaved(station) {
            removeFavorite(station: station)
        } else {
            addFavorite(station)
        }
    }
}

// MARK: FetchStations
extension StationListViewModel {
    /// Fetches all stations.
    func getAllStations() {
        stationsState = .loading
        stationsService.fetchStations()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setFetchStationsError(error)
                    }
                }
            }, receiveValue: { [weak self] (response: StationsResponse) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.setFetchedStations(response.stations)
                }
            })
            .store(in: &cancellables)
    }
    
    /// Sets an error when fetching stations.
    /// - Parameter error: The error to set.
    private func setFetchStationsError(_ error: Error) {
        stationsState = .error(activeStations, error)
    }
    
    /// Sets the fetched stations.
    /// - Parameter stations: The stations to set.
    private func setFetchedStations(_ stations: [Station]) {
        allStations = stations
        stationsState = .loaded(activeStations)
    }
}

// MARK: SavedStations
extension StationListViewModel {
    /// Fetches saved stations.
    func getSavedStations() {
        savedStationsState = .updating(savedStations)
        savedStationsService.getService.fetchSaved()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setFetchStationsError(error)
                    }
                }
            }, receiveValue: { [weak self] (saved: [Station]) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.setSavedStations(saved)
                }
            })
            .store(in: &cancellables)
    }
    
    /// Sets an error when fetching saved stations.
    /// - Parameter error: The error to set.
    private func setSavedStationsError(_ error: Error) {
        savedStationsState = .error(savedStations, error)
    }
    
    /// Sets the saved stations.
    /// - Parameter stations: The stations to set.
    private func setSavedStations(_ stations: [Station]) {
        savedStationsStore.savedStations = Set(stations)
    }
    
    /// Adds a station to favorites.
    /// - Parameter newFavorite: The station to add to favorites.
    func addFavorite(_ newFavorite: Station) {
        savedStationsService.addService.add(station: newFavorite)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setSavedStationsError(error)
                    }
                }
            }, receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.getSavedStations()
                }
            })
            .store(in: &cancellables)
    }
    
    /// Removes a station from favorites.
    /// - Parameter station: The station to remove.
    func removeFavorite(station: Station) {
        savedStationsService.removeService.remove(stations: [station])
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setSavedStationsError(error)
                    }
                }
            }, receiveValue: { [weak self] _ in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.getSavedStations()
                }
            })
            .store(in: &cancellables)
    }
}
