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
                header: Text("Data")
                    .font(.largeTitle)
                    .padding(.bottom)
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
            .padding(.vertical)
        }
    }
}

struct ReportDetailView: View {
    let report: StationDetailsViewModel.StationDailyDataReport
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Date: \(report.date)")
                .font(.title2)
                .padding([.top, .bottom])
            detailRow(title: "Day Air Temp Average", value: report.dayAirTmpAvg)
            detailRow(title: "Day Air Temp Max", value: report.dayAirTmpMax)
            detailRow(title: "Day Air Temp Min", value: report.dayAirTmpMin)
            detailRow(title: "Day Dew Point", value: report.dayDewPnt)
            detailRow(title: "Day ASCE ETo", value: report.dayAsceEto)
            detailRow(title: "Day Precipitation", value: report.dayPrecip)
            detailRow(title: "Day Relative Humidity Average", value: report.dayRelHumAvg)
            detailRow(title: "Day Relative Humidity Max", value: report.dayRelHumMax)
            detailRow(title: "Day Relative Humidity Min", value: report.dayRelHumMin)
//            detailRow(title: "Day Soil Temp Average", value: report.daySoilTmpAvg)
//            detailRow(title: "Day Solar Radiation Average", value: report.daySolRadAvg)
//            detailRow(title: "Day Vapor Pressure Average", value: report.dayVapPresAvg)
//            detailRow(title: "Day Wind Run", value: report.dayWindRun)
//            detailRow(title: "Day Wind Speed Average", value: report.dayWindSpdAvg)
        }
    }
    
    func detailRow(
        title: String,
        value: StationDetailsViewModel.StationDailyDataReport.Value
    ) -> some View {
        VStack(alignment: .leading) {
            Text(title)
            Text("Value: \(value.value) \(value.unit)")
        }
        .padding(.bottom)
    }
}
