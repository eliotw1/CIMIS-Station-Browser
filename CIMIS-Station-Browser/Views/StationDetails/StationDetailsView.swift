//
//  StationDetailsView.swift
//  CIMIS-Station-Browser
//
//  Created by Eliot Williams on 7/24/23.
//

import SwiftUI

struct StationDetailsView: View {
    
    @ObservedObject var viewModel: StationDetailsViewModel
    @State private var appKey: String = ""
    
    init(
        viewModel: StationDetailsViewModel
    ) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            Section(header: dataSectionHeader) {
                EmptyView() // Replace With Data
            }
            Section(header: infoSectionHeader) {
                DetailRow(title: "City", value: viewModel.station.city)
                DetailRow(title: "Is Active", value: viewModel.station.isActive ? "Yes" : "No")
                DetailRow(title: "Is ETO Station", value: viewModel.station.isEtoStation ? "Yes" : "No")
                DetailRow(title: "Elevation", value: "\(viewModel.station.elevation)")
                DetailRow(title: "Ground Cover", value: viewModel.station.groundCover)
                DetailRow(title: "Latitude", value: viewModel.station.hmsLatitude)
                DetailRow(title: "Longitude", value: viewModel.station.hmsLongitude)
                DetailRow(title: "Siting Description", value: viewModel.station.sitingDesc)
                DetailsRow(title: "Zip Codes", values: viewModel.station.zipCodes)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(viewModel.station.name)
        .navigationBarItems(
            trailing:
                Button(
                    action: {
                        viewModel.toggleSaved()
                    }, label: {
                        savedImage
                    }
                )
        )
    }
    
    var savedImage: Image {
        viewModel.savedState.isSaved
        ? Image(systemName: "bookmark.fill")
        : Image(systemName: "bookmark")
    }
    
    var dataSectionHeader: some View {
        VStack(alignment: .leading) {
            Text("Data")
                .font(.largeTitle)
            TextField("YOUR-APP-KEY", text: $appKey)
                .padding()
                .font(.callout)
                .background(Color.gray)
                .cornerRadius(8)
            Button(action: {
                // Your action here
            }, label: {
                Text("Get Daily Station Data")
                    .font(.callout)
                    .foregroundColor(Color.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .cornerRadius(8)
            })
        }
        .padding([.top])
    }
    
    var infoSectionHeader: some View {
        VStack(alignment: .leading) {
            Text(viewModel.station.name)
                .font(.title)
            Text("Station #\(viewModel.station.number)")
                .font(.subheadline)
        }
    }
    
    struct DetailRow: View {
        let title: String
        let value: String
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                Text(value)
                    .font(.subheadline)
            }
            .padding(.vertical, 4)
        }
    }
    
    struct DetailsRow: View {
        let title: String
        let values: [String]
        
        var body: some View {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                ForEach(values, id: \.self) {
                    Text($0)
                        .font(.subheadline)
                }
            }
            .padding(.vertical, 4)
        }
    }
}
