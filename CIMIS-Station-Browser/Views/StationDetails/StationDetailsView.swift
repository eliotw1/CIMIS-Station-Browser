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
            Section(
                header: Text("Daily Report")
                    .font(.largeTitle)
                ,
                footer: dataSectionFooter
            ) {
                switch viewModel.reportState {
                case .none:
                    EmptyView()
                case .loading:
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                case .error(let error):
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding([.top, .bottom])
                case .loaded(let report):
                    ReportDetailView(report: report)
                }
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
                .accessibilityLabel(
                    viewModel.savedState.isSaved
                    ? "Remove From Saved Stations"
                    : "Save Station"
                )
        )
    }
    
    var savedImage: Image {
        viewModel.savedState.isSaved
        ? Image(systemName: "bookmark.fill")
        : Image(systemName: "bookmark")
    }
    
    @ViewBuilder
    var dataSectionFooter: some View {
        switch viewModel.reportState {
        case .none,
                .error:
            VStack(alignment: .leading) {
                TextField("YOUR-APP-KEY", text: $appKey)
                    .padding()
                    .font(.callout)
                    .background(Color.gray)
                    .cornerRadius(8)
                    .accessibilityLabel("App Key")
                Button(action: {
                    viewModel.getData(appKey: appKey)
                }, label: {
                    Text("Get Daily Station Data")
                        .font(.callout)
                        .foregroundColor(Color.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(8)
                })
                .accessibilityHint("Fetches yesterday's daily station data report.")
            }
            .padding([.top])
        default: EmptyView()
        }
    }
    
    var infoSectionHeader: some View {
        VStack(alignment: .leading) {
            Text(viewModel.station.name)
                .font(.title)
            Text("Station #\(viewModel.station.number)")
                .font(.subheadline)
        }
        .accessibilityElement(children: .combine)
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(value)")
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
            .padding(.vertical)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title): " + values.joined(separator: ", "))
        }
    }
}

struct ReportDetailView: View {
    let report: StationDailyDataReport
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(report.date)")
                .font(.title2)
                .padding([.top, .bottom])
            ForEach(report.values, id: \.title) { value in
                ReportDetailRowView(
                    title: value.title,
                    value: value.value,
                    unit: value.unit
                )
            }
        }
    }
}

struct ReportDetailRowView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            Text("Value: \(value) \(unit)")
        }
        .padding(.bottom)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): " + value + unit)
    }
}
