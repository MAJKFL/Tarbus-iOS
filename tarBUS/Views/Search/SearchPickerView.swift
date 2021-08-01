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
            .onReceive(locationhelper.$location, perform: { location in
                guard let location = location?.coordinate else { return }
                getNearestBusStops(location)
            })
        }
    }
    
    func getNearestBusStops(_ location: CLLocationCoordinate2D) {
        tiles.removeAll(where: { $0.isRecomendation })
        withAnimation(.easeIn) {
            for busStop in databaseHelper.getNearestBusStops(lat: location.latitude, lng: location.longitude) {
                tiles.append(SearchTileViewModel(title: busStop.name, imageName: "BusStop", isRecomendation: true, destination: AnyView(BusStopView(busStop: busStop, filteredBusLines: []))))
            }
        }
    }
}

struct SearchTileView: View {
    
    let viewModel: SearchTileViewModel
    
    @State private var animation = false
    
    var body: some View {
        NavigationLink(destination: viewModel.destination) {
            ZStack {
                Image(viewModel.imageName)
                    .resizable()
                    .scaledToFill()
                
                Color("MainColor")
                    .opacity(viewModel.isRecomendation ? 0.3 : 0.6)
                
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "location.fill")
                            .opacity(viewModel.isRecomendation ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(viewModel.title)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(.white)
                .font(.headline.weight(.heavy))
                
                VStack {
                    HStack {
                        Spacer()
                        
                        Image(systemName: "location.fill")
                            .opacity(viewModel.isRecomendation ? 1 : 0)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(viewModel.title)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                }
                .padding()
                .foregroundColor(Color("MainColor"))
                .font(.headline.weight(.heavy))
                .mask(
                    Rectangle()
                        .fill(
                            LinearGradient(gradient: .init(colors: [Color.white.opacity(0.4),Color.white.opacity(0.6),Color.white.opacity(0.4)]), startPoint: .top, endPoint: .bottom)
                        )
                        .rotationEffect(.init(degrees: 70))
                        .padding(20)
                        .offset(x: -250)
                        .offset(x: animation ? 500 : 0)
                )
                .onAppear {
                    if viewModel.isRecomendation {
                        withAnimation(Animation.linear(duration: 2).repeatForever(autoreverses: false)){
                            animation.toggle()
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 15))
            .shadow(radius: 3, x: 3, y: 3)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SearchTileViewModel: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    var isRecomendation = false
    let destination: AnyView
}
