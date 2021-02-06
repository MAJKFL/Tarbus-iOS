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
    
    let busLine: BusLine
    
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
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            routes = dataBaseHelper.getRoutes(busLineId: busLine.id)
        }
    }
}

struct RouteView: View {
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var isShowingRoute = false
    @State private var busStops = [BusStop]()
    @State private var isShowingPreview = true
    
    let route: Route
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.turn.up.right")
                    .foregroundColor(Color("MainColor"))
                
                VStack(alignment: .leading) {
                    if isShowingPreview {
                        VStack(alignment: .leading) {
                            Text(busStops.first?.name ?? "")
                            
                            Image(systemName: "arrow.down")
                            
                            Text(busStops.last?.name ?? "")
                        }
                        .font(.footnote)
                        .lineLimit(1)
                    } else {
                        Text(route.destinationName)
                            .fontWeight(.bold)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isShowingRoute ? 0 : -180))
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1)) {
                    withAnimation(Animation.easeIn(duration: 0.25)) { isShowingPreview = false }
                }
            }
                
            if isShowingRoute {
                BusStopListView(busStops: busStops)
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

struct BusStopListView: View {
    let busStops: [BusStop]
    
    var body: some View {
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
