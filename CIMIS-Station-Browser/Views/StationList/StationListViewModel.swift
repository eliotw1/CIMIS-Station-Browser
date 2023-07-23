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
        case fetching([Station])
        case loaded([Station])
        case error([Station], Error)
    }
    
    @Published var savedState = SavedStationsState.initial
    @Published var stationsState = StationsServiceState.initial
    
    private var allStations = [Station]()
    private var activeStations: [Station] {
        allStations.filter { $0.isActive }
    }
    
    private let stationsProvider: StationsServiceInterface
    private var cancellables = Set<AnyCancellable>()
    
    init(stationsProvider: StationsServiceInterface) {
        self.stationsProvider = stationsProvider
    }
    
    func loadStations() {
        stationsState = .loading
        stationsProvider.fetchStations()
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        self.setError(error)
                    }
                }
            }, receiveValue: { [weak self] (response: StationsResponse) in
                DispatchQueue.main.async {
                    guard let self = self else { return }
                    self.setStations(response.stations)
                }
            })
            .store(in: &cancellables)
    }
    
    func setError(_ error: Error) {
        stationsState = .error(activeStations, error)
    }
    
    func setStations(_ stations: [Station]) {
        allStations = stations
        stationsState = .loaded(activeStations)
    }
    
    func cancelRequests() {
        cancellables.forEach { $0.cancel() }
    }
}
