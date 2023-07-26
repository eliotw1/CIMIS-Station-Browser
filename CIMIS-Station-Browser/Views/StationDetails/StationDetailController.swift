//
//  StationDetailController.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import Foundation

class StationDetailController {
    let router: RouterInterface
    let services: ServicesInterface
    let store: SavedStationStore
    let station: Station

    init(
        station: Station,
        router: RouterInterface,
        services: ServicesInterface,
        store: SavedStationStore
    ) {
        self.station = station
        self.router = router
        self.services = services
        self.store = store
    }

    func createStationDetailsView() -> StationDetailsView {
        let viewModel = StationDetailsViewModel(
            station: station,
            savedStationsStore: store,
            stationsDataService: services.stationDataService,
            savedStationsService: services.savedStationsService
        )
        let view = StationDetailsView(viewModel: viewModel)
        return view
    }
}

