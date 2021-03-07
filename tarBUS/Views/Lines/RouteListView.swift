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
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var isShowingRoute = false
    @State private var busStops = [BusStop]()
    
    let route: Route
    let busLine: BusLine
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.turn.up.right")
                    .foregroundColor(Color("MainColor"))
                
                VStack(alignment: .leading) {
                    Text(route.destinationName)
                        .fontWeight(.bold)
                    
                    Text(route.description)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isShowingRoute ? 0 : -180))
            }
            .padding()
                
            if isShowingRoute {
                BusStopListView(busStops: busStops, busLine: busLine)
            }
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(radius: 5, x: 5, y: 5)
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
                            Image("firstBusStop")
                                .busStopLabel()
                        case busStops.count - 1:
                            Image("lastBusStop")
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
                    .padding(.horizontal)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
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
