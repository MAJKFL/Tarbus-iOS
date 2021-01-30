//
//  PlanView.swift
//  tarBUS
//
//  Created by Kuba Florek on 30/01/2021.
//

import SwiftUI

struct PlanView: View {
    enum dayTypes: String, CaseIterable {
        case workingDays = "Dni robocze"
        case saturdays = "Soboty"
        case holidays = "Święta"
    }
    
    let busStop: BusStop
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var dayType: dayTypes = .workingDays
    @State private var routes = [Route]()
    @State private var departures = [Departure]()
    
    var body: some View {
        VStack {
            Picker("Dzień", selection: $dayType.animation(.easeOut)) {
                ForEach(dayTypes.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding([.top, .horizontal])
            .padding(.bottom, 5)
            
            switch dayType {
            case .workingDays:
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(routes) { route in
                            RouteCellView(route: route, busStop: busStop, dayTypeIntValue: 1)
                        }
                    }
                }
                .transition(.slide)
            case .saturdays:
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(routes) { route in
                            RouteCellView(route: route, busStop: busStop, dayTypeIntValue: 2)
                        }
                    }
                }
                .transition(.slide)
            default:
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(routes) { route in
                            RouteCellView(route: route, busStop: busStop, dayTypeIntValue: 3)
                        }
                    }
                }
                .transition(.slide)
            }
        }
        .transition(AnyTransition.opacity.combined(with: .move(edge: .trailing)))
        .onAppear {
            routes = dataBaseHelper.getDestinations(busStopId: busStop.id)
        }
    }
    
    
}

struct RouteCellView: View {
    @StateObject var dataBaseHelper = DataBaseHelper()
    let route: Route
    let busStop: BusStop
    let dayTypeIntValue: Int
    @State private var showHours = false
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: "bus.fill")
                    
                    Text(dataBaseHelper.getBusLine(busLineId: route.busLineId).name)
                }
                .font(Font.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: 100, minHeight: 50)
                .background(Color("MainColor"))
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                
                Text("\(route.destinationName)")
                    .font(.title)
                
                Spacer()
            }
            
            if showHours {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(getDepartures()) { departure in
                        HStack(spacing: 0) {
                            Text(departure.timeString)
                            
                            if departure.symbols != "-" {
                                Text(departure.symbols)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                }
                .padding(.bottom, 10)
            }
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.spring()) { showHours.toggle() }
        }
    }
    
    func getDepartures() -> [Departure] {
        return dataBaseHelper.getDepartures(busStopId: busStop.id, dayType: dayTypeIntValue).filter({ $0.busLineId == route.busLineId })
    }
}
