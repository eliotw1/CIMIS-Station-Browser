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
    
    @Published var savedStationsState = SavedStationsState.initial
    @Published var stationsState = StationsServiceState.initial
    
    private var savedStations = [Station]()
    
    private var allStations = [Station]()
    private var activeStations: [Station] {
        allStations.filter { $0.isActive }
    }
    
    private let savedStationsService: SavedStationServiceInterface
    private let stationsService: FetchStationsServiceInterface
    private var cancellables = Set<AnyCancellable>()
    
    init(
        stationsService: FetchStationsServiceInterface,
        savedStationsService: SavedStationServiceInterface
    ) {
        self.stationsService = stationsService
        self.savedStationsService = savedStationsService
        getSavedStations()
    }
    
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
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
        savedStationsService.getSaved()
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
        savedStations = stations
        savedStationsState = .loaded(stations)
    }
    
    func addFavorite(_ newFavorite: Station) {
        savedStationsService.add(station: newFavorite)
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
        savedStationsService.remove(stations: [station])
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
