//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 27/01/2021.
//

import SwiftUI

struct RouteListView: View {
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    @ObservedObject var favouriteBusLinesViewModel = FavouriteBusLinesViewModel()
    @State private var routes = [Route]()
    
    let busLine: BusLine
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(routes) { route in
                    RouteView(route: route, busLine: busLine)
                }
                
                Spacer()
            }
        }
        .navigationTitle("\(busLine.name) - Kierunki")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarItems(trailing: Button(action: {
            if favouriteBusLinesViewModel.busLines.contains(where: { $0.id == busLine.id }) {
                favouriteBusLinesViewModel.remove(id: busLine.id)
            } else {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                favouriteBusLinesViewModel.add(busLine)
            }
        }, label: {
            Image(systemName: favouriteBusLinesViewModel.busLines.contains(where: { $0.id == busLine.id }) ? "heart.fill" : "heart")
        }))
        .onAppear {
            routes = dataBaseHelper.getRoutes(busLineId: busLine.id)
        }
    }
}

fileprivate struct RouteView: View {
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var isShowingRoute = false
    @State private var busStops = [BusStop]()
    
    let route: Route
    let busLine: BusLine
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Cel")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(route.destinationName)
                        .font(.title3)
                }
                
                Spacer()
                
                Button(action: {}) {
                    HStack {
                        Image(systemName: "map")
                        
                        Text("Mapa")
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text("Przez")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    
                if isShowingRoute {
                    BusStopListView(busStops: busStops, busLine: busLine)
                } else {
                    PlaceListView()
                }
            }
            
            VStack {
                Text(isShowingRoute ? "Zwiń" : "Rozwiń")
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isShowingRoute ? -180 : 0))
            }
            .font(.headline)
        }
        .padding()
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(radius: 2, x: 2, y: 2)
        .padding([.top, .horizontal])
        .onAppear {
            busStops = dataBaseHelper.getBusStops(routeId: route.id)
        }
        .onTapGesture {
            withAnimation(.spring()) { isShowingRoute.toggle() }
        }
    }
}

fileprivate struct BusStopListView: View {
    let busStops: [BusStop]
    let busLine: BusLine
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(busStops.indices) { index in
                NavigationLink(destination: BusStopView(busStop: busStops[index], filteredBusLines: [busLine])) {
                    HStack {
                        switch(index) {
                        case 0:
                            Image("routeFirstBusStop")
                                .busStopLabel()
                        case busStops.count - 1:
                            Image("routeLastBusStop")
                                .busStopLabel()
                        default:
                            Image("routeBusStop")
                                .busStopLabel()
                        }
                        
                        Text(busStops[index].name)
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    .frame(maxHeight: 50)
                    .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

fileprivate struct PlaceListView: View {
    let places = [1, 2, 3, 4]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(places.indices, id: \.self) { index in
                HStack {
                    switch(index) {
                    case 0:
                        Image("routeFirstBusStop")
                            .busStopLabel()
                    case places.count - 1:
                        Image("routeLastBusStop")
                            .busStopLabel()
                    default:
                        Image("routeBusStop")
                            .busStopLabel()
                    }
                    
                    Text("Miejscowość\(places[index])")
                        .lineLimit(1)
                    
                    Spacer()
                }
                .frame(maxHeight: 50)
                .font(.headline)
            }
        }
    }
}
