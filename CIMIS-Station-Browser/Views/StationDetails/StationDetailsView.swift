//
//  StationDetailsView.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import SwiftUI

struct StationDetailsView: View {
    
    @ObservedObject var viewModel: StationDetailsViewModel
    
    init(
        viewModel: StationDetailsViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        stationDetails
            .navigationTitle(viewModel.station.name)
            .navigationBarItems(
                trailing:
                    Button(action: {
                        viewModel.toggleSaved()
                    }, label: {
                        savedImage
                    })
            )
    }
    
    var savedImage: Image {
        viewModel.savedState.isSaved
        ? Image(systemName: "bookmark.fill")
        : Image(systemName: "bookmark")
    }
    
    var stationDetails: some View {
        VStack {
            Text(viewModel.station.name)
            Text("Station #\(viewModel.station.number)")
            if !viewModel.station.zipCodes.isEmpty {
                Text("Supported Zip Codes: " + viewModel.station.zipCodes.joined(separator: ", "))
            }
        }
    }
}
