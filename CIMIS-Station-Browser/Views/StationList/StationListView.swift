//
//  StationListView.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/23/23.
//

import SwiftUI

struct StationListView: View {
    
    init(
        stationsService: FetchStationsServiceInterface,
        savedStationsService: SavedStationServiceInterface
    ) {
        self.viewModel = StationListViewModel(
            stationsService: stationsService,
            savedStationsService: savedStationsService
        )
    }
    
    @ObservedObject private var viewModel: StationListViewModel
    
    var body: some View {
        NavigationView {
            content
                .navigationTitle("CIMIS Stations")
                .navigationBarItems(
                    trailing:
                        Button(action: {
                            viewModel.getAllStations()
                        }, label: {
                            Image(systemName: "arrow.clockwise")
                        })
                        .disabled(!isRefreshButtonEnabled)
                )
                .onAppear(perform: didAppear)
        }
    }
    
    @ViewBuilder
    private var content: some View {
        List {
            savedSection
            activeSection
        }
    }
}

internal extension StationListView {
    
    func didAppear() {
        guard case .initial = viewModel.stationsState else { return }
        viewModel.getAllStations()
    }
    
    @ViewBuilder
    var loadingView: some View {
        VStack(alignment: .center) {
            ProgressView("Loading stations...")
                .frame(maxWidth: .infinity)
        }
        .padding(.init(
            top: 8,
            leading: 24,
            bottom: 8,
            trailing: 24)
        )
    }
    
    func errorGroup(_ error: Error) -> some View {
        Group {
            Text(error.localizedDescription)
            Button(action: {
                viewModel.getAllStations()
            }, label: {
                Text("Retry")
            })
        }
        .padding(
            .init(
                top: 8,
                leading: 0,
                bottom: 8,
                trailing: 0
            )
        )
    }
    
    @ViewBuilder
    var savedSection: some View {
        if !viewModel.savedStationsState.savedStations.isEmpty {
            Section("Saved") {
                ForEach(viewModel.savedStationsState.savedStations, id: \.number) {
                    stationRow($0)
                }
            }
        }
    }
    
    @ViewBuilder
    var activeSection: some View {
        Section("Active") {
            activeHeader
            switch viewModel.stationsState {
            case .loaded(let allStations),
                    .error(let allStations, _):
                activeStations(allStations)
            default:
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    var activeHeader: some View {
        switch viewModel.stationsState {
        case .error(_, let error):
            errorGroup(error)
        case .initial,
                .loading:
            loadingView
        case .loaded:
            EmptyView()
        }
    }

    func activeStations(_ stations: [Station]) -> some View {
        ForEach(
            stations.filter({ !isSaved($0) }),
            id: \.number
        ) { station in
            stationRow(station)
        }
    }
    
    func stationRow(_ station: Station) -> some View {
        HStack(spacing: 16.0) {
            Image(
                systemName: isSaved(station)
                ? "bookmark.fill"
                : "bookmark")
                .onTapGesture { toggleSaved(station) }
            NavigationLink {
                VStack {
                    Text(station.name)
                    Text("Station #\(station.number)")
                    if !station.zipCodes.isEmpty {
                        Text("Supported Zip Codes: " + station.zipCodes.joined(separator: ", "))
                    }
                }
            } label: {
                VStack(alignment: .leading) {
                    Text(station.name + ":  #\(station.number)")
                }
            }
        }
    }
    
    var isRefreshButtonEnabled: Bool {
        switch viewModel.stationsState {
        case .loaded,
                .error,
                .initial:
            return true
        case .loading:
            return false
        }
    }
}

extension StationEntity {
    func update(with station: Station) {
        number = station.number
        name = station.name
        city = station.city
        isActive = station.isActive
        isEtoStation = station.isEtoStation
        elevation = Int16(station.elevation)
        groundCover = station.groundCover
        hmsLatitude = station.hmsLatitude
        hmsLongitude = station.hmsLongitude
        sitingDesc = station.sitingDesc
        zipCodes = station.zipCodes.joined(separator: ",")
    }
    
    func toStation() -> Station? {
        Station(entity: self)
    }
}

extension Station {
    init?(entity: StationEntity) {
        guard let number = entity.number,
              let name = entity.name,
              let city = entity.city,
              let groundCover = entity.groundCover,
              let hmsLatitude = entity.hmsLatitude,
              let hmsLongitude = entity.hmsLongitude,
              let sitingDesc = entity.sitingDesc,
              let zipCodes = entity.zipCodes else {
            return nil
        }
        
        self.number = number
        self.name = name
        self.city = city
        self.isActive = entity.isActive
        self.isEtoStation = entity.isEtoStation
        self.elevation = Int(entity.elevation)
        self.groundCover = groundCover
        self.hmsLatitude = hmsLatitude
        self.hmsLongitude = hmsLongitude
        self.sitingDesc = sitingDesc
        self.zipCodes = zipCodes.components(separatedBy: ",")
    }
}

internal extension StationListView {
    
    func isSaved(_ station: Station) -> Bool {
        viewModel.savedStationsState.savedStations.contains(where: { $0.number == station.number })
    }
    
    func toggleSaved(_ station: Station) {
        if isSaved(station) {
            viewModel.removeFavorite(station: station)
//            removeFavorite(stationNumber: station.number)
        } else {
//            addFavorite(station)
            viewModel.addFavorite(station)
        }
    }
    
//    private func addFavorite(_ station: Station) {
//        withAnimation {
//            savedStations
//                .filter { $0.number == station.number }
//                .forEach(viewContext.delete(_:))
//            let newFavorite = StationEntity(context: viewContext)
//            newFavorite.update(with: station)
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
//
//    private func removeFavorite(stationNumber: String) {
//        withAnimation {
//            savedStations
//                .filter { $0.number == stationNumber }
//                .forEach(viewContext.delete(_:))
//
//            do {
//                try viewContext.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nsError = error as NSError
//                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
//            }
//        }
//    }
}

#if DEBUG
struct StationListView_Previews: PreviewProvider {
    
    @Environment(\.managedObjectContext) private var viewContext
    
    static var previews: some View {
        Group {
            StationListView(
                stationsService: MockFetchStationsService(),
                savedStationsService: SavedStationServiceContainer(
                    getService: FetchSavedStationsService(context: PersistenceController.preview.container.viewContext),
                    addService: AddSavedStationService(context: PersistenceController.preview.container.viewContext),
                    removeService: RemoveSavedStationService(context: PersistenceController.preview.container.viewContext)
                )
            )
        }
    }
}
#endif
