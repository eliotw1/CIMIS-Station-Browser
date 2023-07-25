//
//  StationDetailsViewModel.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import Foundation
import Combine

class StationDetailsViewModel: ObservableObject {
    
    enum SavedState {
        case loaded(saved: Bool)
        case updating(saved: Bool)
        case error(saved: Bool, error: Error)
        
        var isSaved: Bool {
            switch self {
            case .loaded(let saved),
                    .updating(let saved),
                    .error(let saved, _):
                return saved
            }
        }
        
        var isUpdating: Bool {
            guard case .updating = self else { return false }
            return true
        }
    }
    
    enum ReportState {
        case none
        case loaded
        case error
    }
    
    @Published private(set) var reportState: ReportState
    @Published private(set) var savedState: SavedState
    @Published private(set) var station: Station
    
    private let stationsService: FetchStationsServiceInterface
    private let savedStationsService: SavedStationServiceInterface
    private let savedStationsStore: SavedStationStore
    
    private var cancellables = Set<AnyCancellable>()
    
    private var isSaved: Bool {
        savedStationsStore.savedStations.contains(station)
    }
    
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
        
        savedStationsStore.savedStationsChanged.sink { [weak self] _ in
            guard let self = self else { return }
            self.savedState = .loaded(saved: self.isSaved)
        }.store(in: &cancellables)
    }
    
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: Saved Logic
extension StationDetailsViewModel {
    
    func toggleSaved() {
        if isSaved {
            removeFavorite()
        } else {
            addFavorite()
        }
    }
    
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
