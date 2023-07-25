//
//  StationListController.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/25/23.
//

import Foundation

class StationListController {
    let router: RouterInterface
    let services: ServicesInterface
    let store: SavedStationStore
    
    weak var child: StationDetailController?

    init(
        router: RouterInterface,
        services: ServicesInterface,
        store: SavedStationStore
    ) {
        self.router = router
        self.services = services
        self.store = store
    }

    func createStationListView() -> StationListView {
        let viewModel = StationListViewModel(
            stationsService: services.fetchStationsService,
            savedStationsService: services.savedStationsService,
            savedStationsStore: store
        )
        var view = StationListView(viewModel: viewModel)
        view.actions.onRowTap = {
            self.onRowTap(station: $0)
        }
        return view
    }
    
    func onRowTap(station: Station) {
        let child = StationDetailController(
            station: station,
            router: router,
            services: services,
            store: store
        )
        self.child = child
        DispatchQueue.main.async {
            let view = child.createStationDetailsView()
            self.router.navigate(to: .detail(view), animated: true)
        }
    }
}
