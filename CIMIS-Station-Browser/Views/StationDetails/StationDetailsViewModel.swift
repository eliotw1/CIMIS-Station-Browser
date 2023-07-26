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
    
    struct StationDailyDataReport {
        // init from DataResponse
        let date: String
        let dayAirTmpAvg: Value
        let dayAirTmpMax: Value
        let dayAirTmpMin: Value
        let dayDewPnt: Value
        let dayAsceEto: Value
        let dayPrecip: Value
        let dayRelHumAvg: Value
        let dayRelHumMax: Value
        let dayRelHumMin: Value
        let daySoilTmpAvg: Value
        let daySolRadAvg: Value
        let dayVapPresAvg: Value
        let dayWindRun: Value
        let dayWindSpdAvg: Value
        
        struct Value: Codable {
            let value: String
            let qc: String
            let unit: String
        }
    }
    
    /// Enum representing the state of the station report.
    enum ReportState {
        case none
        case loading
        case loaded(StationDailyDataReport)
        case error(Error)
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
    
    /// Service to fetch station data.
    private let stationsDataService: StationDataServiceInterface
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
    /// - Parameter stationsDataService: `StationDataServiceInterface`
    /// - Parameter savedStationsService: `SavedStationServiceInterface`
    init(
        station: Station,
        savedStationsStore: SavedStationStore,
        stationsDataService: StationDataServiceInterface,
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
        self.stationsDataService = stationsDataService
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
    
    /// Fetches Yesterday's data for the station
    /// - Parameter appKey: an app key with which to use the api
    func getData(appKey: String) {
        guard let id = Int(station.number),
              !appKey.isEmpty else { return }
        reportState = .loading
        stationsDataService.getData(
            for: id,
            startDate: .yesterdayInPacificTime,
            endDate: .yesterdayInPacificTime,
            appKey: appKey
        )
        .sink(receiveCompletion: { [weak self] completion in
            switch completion {
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.reportState = .error(error)
                }
            case .finished:
                break
            }
        }, receiveValue: { [weak self] dataResponse in
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                guard let report = self.createStationDailyDataReport(from: dataResponse) else {
                    DispatchQueue.main.async {
                        self.reportState = .error(
                            ServiceError.badResponseData(message: "Unable to parse report")
                        )
                    }
                    return
                }
                self.reportState = .loaded(report)
            }
        })
        .store(in: &cancellables)
    }
    
    private func createStationDailyDataReport(from dataResponse: DataResponse) -> StationDailyDataReport? {
        guard let provider = dataResponse.data.providers.first,
              let record = provider.records.first else { return nil }
        
        return StationDailyDataReport(
            date: record.date,
            dayAirTmpAvg: .init(value: record.dayAirTmpAvg.value, qc: record.dayAirTmpAvg.qc, unit: record.dayAirTmpAvg.unit),
            dayAirTmpMax: .init(value: record.dayAirTmpMax.value, qc: record.dayAirTmpMax.qc, unit: record.dayAirTmpMax.unit),
            dayAirTmpMin: .init(value: record.dayAirTmpMin.value, qc: record.dayAirTmpMin.qc, unit: record.dayAirTmpMin.unit),
            dayDewPnt: .init(value: record.dayDewPnt.value, qc: record.dayDewPnt.qc, unit: record.dayDewPnt.unit),
            dayAsceEto: .init(value: record.dayAsceEto.value, qc: record.dayAsceEto.qc, unit: record.dayAsceEto.unit),
            dayPrecip: .init(value: record.dayPrecip.value, qc: record.dayPrecip.qc, unit: record.dayPrecip.unit),
            dayRelHumAvg: .init(value: record.dayRelHumAvg.value, qc: record.dayRelHumAvg.qc, unit: record.dayRelHumAvg.unit),
            dayRelHumMax: .init(value: record.dayRelHumMax.value, qc: record.dayRelHumMax.qc, unit: record.dayRelHumMax.unit),
            dayRelHumMin: .init(value: record.dayRelHumMin.value, qc: record.dayRelHumMin.qc, unit: record.dayRelHumMin.unit),
            daySoilTmpAvg: .init(value: record.daySoilTmpAvg.value, qc: record.daySoilTmpAvg.qc, unit: record.daySoilTmpAvg.unit),
            daySolRadAvg: .init(value: record.daySolRadAvg.value, qc: record.daySolRadAvg.qc, unit: record.daySolRadAvg.unit),
            dayVapPresAvg: .init(value: record.dayVapPresAvg.value, qc: record.dayVapPresAvg.qc, unit: record.dayVapPresAvg.unit),
            dayWindRun: .init(value: record.dayWindRun.value, qc: record.dayWindRun.qc, unit: record.dayWindRun.unit),
            dayWindSpdAvg: .init(value: record.dayWindSpdAvg.value, qc: record.dayWindSpdAvg.qc, unit: record.dayWindSpdAvg.unit)
        )
    }
    
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
