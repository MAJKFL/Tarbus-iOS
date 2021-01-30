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
                    NavigationLink(destination: BusStopListView(busStops: dataBaseHelper.getBusStops(routeId: route.id), routeName: route.destinationName)) {
                        Text(route.destinationName)
                            .font(Font.largeTitle.bold())
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width - 50, height: 100)
                            .background(Color("MainColor"))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .padding([.top, .horizontal])
                    }
                    .buttonStyle(PlainButtonStyle())
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

struct BusStopListView: View {
    let busStops: [BusStop]
    let routeName: String
    
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
            .navigationTitle(routeName)
            .navigationBarTitleDisplayMode(.large)
        }
    }
}
