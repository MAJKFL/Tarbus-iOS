//
//  SearchView.swift
//  tarBUS
//
//  Created by Kuba Florek on 06/02/2021.
//

import SwiftUI
import CoreLocation

struct SearchPickerView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @ObservedObject var locationhelper = LocationHelper()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    @State private var tiles = [
        SearchTileViewModel(title: "Przystanki", imageName: "BusStop", destination: AnyView(SearchBusStopsView())),
        SearchTileViewModel(title: "Linie", imageName: "BusLine", destination: AnyView(SearchBusLinesView()))
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(tiles) { tile in
                        SearchTileView(viewModel: tile)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Wyszukaj")
            .onAppear {
                guard let location = locationhelper.location?.coordinate else { return }
                getNearestBusStops(location, isFirst: true)
            }
            .onReceive(locationhelper.$location, perform: { location in
                guard let location = location?.coordinate else { return }
                getNearestBusStops(location, isFirst: false)
            })
        }
    }
    
    func getNearestBusStops(_ location: CLLocationCoordinate2D, isFirst: Bool) {
        let nearestBusStops = databaseHelper.getNearestBusStops(lat: location.latitude, lng: location.longitude)
        
        if !isFirst {
            guard nearestBusStops.count == 2 else { return }
            guard !tiles.contains(where: { $0.busStop?.id == nearestBusStops[0].id || $0.busStop?.id == nearestBusStops[1].id }) else { return }
        }
        
        tiles.removeAll(where: { $0.isRecomendation })
        
        withAnimation(.easeIn) {
            for busStop in nearestBusStops {
                tiles.append(SearchTileViewModel(title: busStop.name, imageName: "BusStop", busStop: busStop))
            }
        }
    }
}
