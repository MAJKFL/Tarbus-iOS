//
//  SearchView.swift
//  tarBUS
//
//  Created by Kuba Florek on 06/02/2021.
//

import SwiftUI
import CoreLocation

struct SearchView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @ObservedObject var locationhelper = LocationHelper()
    
    @AppStorage("IsLocationPromptDismissed") var isLocationPromptDismissed = false
    
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
                    
                    if !locationhelper.isLocationAvailable && !isLocationPromptDismissed {
                        locationNotAvailableTile()
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Wyszukaj")
            .onAppear {
                print("startUpdatingLocation")
                locationhelper.startUpdatingLocation()
                guard let location = locationhelper.location?.coordinate else { return }
                getNearestBusStops(location, isFirst: true)
            }
            .onReceive(locationhelper.$location, perform: { location in
                guard let location = location?.coordinate else { return }
                getNearestBusStops(location, isFirst: false)
            })
            .onDisappear {
                print("stopUpdatingLocation")
                locationhelper.stopUpdatingLocation()
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    func getNearestBusStops(_ location: CLLocationCoordinate2D, isFirst: Bool) {
        let nearestBusStops = databaseHelper.getNearestBusStops(lat: location.latitude, lng: location.longitude)
        
        if !isFirst {
            guard nearestBusStops.count == 2 else { return }

            let doesContainFrst = tiles.contains(where: { $0.busStop?.id == nearestBusStops[0].id })
            let doesContainScnd = tiles.contains(where: { $0.busStop?.id == nearestBusStops[1].id })
            
            if doesContainFrst && doesContainScnd { return }
        }
        
        tiles.removeAll(where: { $0.isRecomendation })
        
        withAnimation(.easeIn) {
            for busStop in nearestBusStops {
                tiles.append(SearchTileViewModel(title: busStop.name, imageName: "BusStop", busStop: busStop))
            }
        }
    }
}

struct locationNotAvailableTile: View {
    @AppStorage("IsLocationPromptDismissed") var isLocationPromptDismissed = false
    
    var body: some View {
        Button(action: {
            if let bundleId = Bundle.main.bundleIdentifier,
               let url = URL(string: "\(UIApplication.openSettingsURLString)&path=LOCATION/\(bundleId)") {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }) {
            ZStack {
                VStack {
                    Image(systemName: "location.slash.fill")
                    
                    Spacer()
                    
                    Text("Brak przystanków")
                    
                    Text("Ustawienia")
                        .foregroundColor(.blue)
                        .font(.footnote)
                }
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
                .background(Color("lightGray"))
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeIn) { isLocationPromptDismissed = true }
                        }, label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .padding(10)
                        })
                    }
                    
                    Spacer()
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 3, x: 3, y: 3)
    }
}
