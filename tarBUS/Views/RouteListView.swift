//
//  RouteListView.swift
//  tarBUS
//
//  Created by Kuba Florek on 27/01/2021.
//

import SwiftUI

struct RouteListView: View {
    let busLine: BusLine
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var routes = [Route]()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(routes) { route in
                    RouteView(route: route)
                }
                
                Spacer()
            }
        }
        .navigationTitle("\(busLine.name) - Kierunki")
        .onAppear {
            routes = dataBaseHelper.getRoutes(busLineId: busLine.id)
        }
    }
}

struct RouteView: View {
    @StateObject var dataBaseHelper = DataBaseHelper()
    let route: Route
    @State private var isShowingRoute = false
    
    var body: some View {
        VStack {
            HStack {
                Text(route.destinationName)
                    .fontWeight(.bold)
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isShowingRoute ? 0 : -180))
            }
            .padding(.horizontal)
            .frame(height: 50)
                
                
        
            if isShowingRoute {
                BusStopListView(busStops: dataBaseHelper.getBusStops(routeId: route.id))
            }
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .shadow(radius: 5, x: 5, y: 5)
        .padding([.top, .horizontal])
        .onTapGesture {
            withAnimation(.spring()) { isShowingRoute.toggle() }
        }
    }
}

struct BusStopListView: View {
    let busStops: [BusStop]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                ForEach(busStops.indices) { index in
                    NavigationLink(destination: BusStopView(busStop: busStops[index])) {
                        HStack {
                            switch(index) {
                            case 0:
                                Image("firstBusStop")
                            case busStops.count - 1:
                                Image("lastBusStop")
                            default:
                                Image("nextBusStop")
                            }
                            
                            Text(busStops[index].name)
                            
                            Spacer()
                        }
                        .font(.headline)
                        .padding(.horizontal)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
    }
}
