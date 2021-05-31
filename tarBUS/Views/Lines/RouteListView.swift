//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 27/01/2021.
//

import SwiftUI

struct RouteListView: View {
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var routes = [Route]()
    @ObservedObject var favouriteBusLinesViewModel = FavouriteBusLinesViewModel()
    
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
    @StateObject var databaseHelper = DataBaseHelper()
    @State private var isShowingRoute = false
    @State private var busStops = [BusStop]()
    
    let route: Route
    let busLine: BusLine
    
    var connections: [BusStopConnection] {
        var connections = [BusStopConnection]()
        for index in busStops.indices {
            if index + 1 != busStops.count {
                connections += databaseHelper.getBusStopConnections(fromId: busStops[index].id, toId: busStops[index + 1].id)
            }
        }
        return connections
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Text("cel:")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text(route.destinationName)
                        .font(.headline)
                }
                
                Spacer()
                
                NavigationLink(
                    destination: TrackMapView(connections: connections, busStops: busStops, busStop: nil),
                    label: {
                        Label("Mapa", systemImage: "map")
                    })
            }
            .padding([.top, .horizontal])
                
            if isShowingRoute {
                BusStopListView(busStops: busStops, busLine: busLine)
            } else {
                TownListView(towns: route.towns)
            }
            
            VStack {
                if isShowingRoute {
                    Image(systemName: "chevron.up")
                    Text("Zwiń")
                } else {
                    Text("Rozwiń")
                    Image(systemName: "chevron.down")
                }
            }
            .font(.footnote.bold())
            .foregroundColor(.secondary)
            .padding(.bottom)
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(radius: 2, x: 2, y: 2)
        .padding([.top, .horizontal])
        .onAppear {
            busStops = databaseHelper.getBusStops(routeId: route.id)
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
            Text("przez:")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            ForEach(busStops.indices) { index in
                NavigationLink(destination: BusStopView(busStop: busStops[index], filteredBusLines: [busLine])) {
                    HStack {
                        switch(index) {
                        case 0:
                            Image("firstBusStopWhite")
                                .busStopLabel()
                        case busStops.count - 1:
                            Image("lastBusStopWhite")
                                .busStopLabel()
                        default:
                            Image("nextBusStop")
                                .busStopLabel()
                        }
                        
                        Text(busStops[index].name)
                            .lineLimit(2)
                        
                        Spacer()
                    }
                    .frame(maxHeight: 50)
                    .font(.headline)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
    }
}

fileprivate struct TownListView: View {
    let towns: [String]
    
    var body: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            Text("przez:")
                .font(.footnote)
                .foregroundColor(.secondary)
            
            ForEach(towns.indices) { index in
                HStack {
                    switch(index) {
                    case 0:
                        Image("firstBusStopWhite")
                            .busStopLabel()
                    case towns.count - 1:
                        Image("lastBusStopWhite")
                            .busStopLabel()
                    default:
                        Image("nextBusStop")
                            .busStopLabel()
                    }
                    
                    Text(towns[index])
                        .lineLimit(1)
                    
                    Spacer()
                }
                .frame(maxHeight: 50)
                .font(.headline)
            }
        }
        .padding(.horizontal)
    }
}

extension Image {
    func busStopLabel() -> some View {
        self
            .resizable()
            .scaledToFit()
            .frame(minWidth: 15)
    }
}
