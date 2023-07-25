//
//  StationListViewModel.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import Foundation
import Combine

class StationListViewModel: ObservableObject {
    
    enum StationsServiceState {
        case initial
        case loading
        case loaded([Station])
        case error([Station], Error)
    }
    
    enum SavedStationsState {
        case initial
        case updating([Station])
        case loaded([Station])
        case error([Station], Error)
        
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
    
    @Published var activeStation: Station? = nil
    @Published private(set) var savedStationsState = SavedStationsState.initial
    @Published private(set) var stationsState = StationsServiceState.initial
    
    private let savedStationsStore: SavedStationStore
    
    private var savedStations: [Station] {
        Array(savedStationsStore.savedStations)
    }
    
    private var allStations = [Station]()
    private var activeStations: [Station] {
        allStations.filter { $0.isActive }
    }
    
    private let savedStationsService: SavedStationServiceInterface
    private let stationsService: FetchStationsServiceInterface
    private var cancellables = Set<AnyCancellable>()
    
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
    
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: Station Details
extension StationListViewModel {
    func isSaved(_ station: Station) -> Bool {
        savedStations.contains(where: { $0.number == station.number })
    }
    
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
    
    private func setFetchStationsError(_ error: Error) {
        stationsState = .error(activeStations, error)
    }
    
    private func setFetchedStations(_ stations: [Station]) {
        allStations = stations
        stationsState = .loaded(activeStations)
    }
}

// MARK: SavedStations
extension StationListViewModel {
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
    
    private func setSavedStationsError(_ error: Error) {
        savedStationsState = .error(savedStations, error)
    }
    
    private func setSavedStations(_ stations: [Station]) {
        savedStationsStore.savedStations = Set(stations)
    }
    
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
