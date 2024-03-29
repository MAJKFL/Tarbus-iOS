//
//  PlanView.swift
//  tarBUS
//
//  Created by Kuba Florek on 30/01/2021.
//

import SwiftUI

enum dayTypes: String, CaseIterable {
    case workingDays = "Robocze"
    case saturdays = "Soboty"
    case holidays = "Święta"
    
    var databaseQuery: String {
        switch self {
        case .holidays:
            return "instr(Track.t_day_types, \'SW\')"
        case .saturdays:
            return "instr(Track.t_day_types, \'WS\')"
        default:
            return "instr(Track.t_day_types, \'RO\') OR instr(Track.t_day_types, \'SC\')"
        }
    }
}

struct PlanView: View {
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    @State private var dayType: dayTypes = .workingDays
    @State private var routes = [Route]()
    
    let busStop: BusStop
    
    var body: some View {
        VStack {
            Text(busStop.name)
                .bold()
                .padding(.top)
            
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
                            RouteTileView(route: route, busStop: busStop, dayType: dayType)
                        }
                    }
                    .padding(.bottom, 25)
                }
                .transition(.slide)
            case .saturdays:
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(routes) { route in
                            RouteTileView(route: route, busStop: busStop, dayType: dayType)
                        }
                    }
                    .padding(.bottom, 25)
                }
                .transition(.slide)
            default:
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(routes) { route in
                            RouteTileView(route: route, busStop: busStop, dayType: dayType)
                        }
                    }
                    .padding(.bottom, 25)
                }
                .transition(.slide)
            }
        }
        .transition(AnyTransition.opacity.combined(with: .move(edge: .trailing)))
        .onAppear {
            if routes.isEmpty {
                routes = dataBaseHelper.getDestinations(busStopId: busStop.id)
            }
        }
    }
    
    
}

fileprivate struct RouteTileView: View {
    @StateObject var dataBaseHelper = DataBaseHelper()
    @State private var showHours = false
    @State private var departures = [BoardDeparture]()
    @State private var busLineName = ""
    
    let route: Route
    let busStop: BusStop
    let dayType: dayTypes
    
    var legend: [String] {
        var legendArray = [String]()
        
        for departure in departures {
            if departure.legend != "-" {
                legendArray.append(departure.legend)
            }
        }
        
        return legendArray.removeDuplicates()
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                VStack {
                    HStack {
                        Image(systemName: "note.text")
                        
                        Text(busLineName)
                    }
                    
                    Text(dayType.rawValue)
                        .font(.footnote)
                }
                .font(Font.headline.weight(.bold))
                .foregroundColor(.white)
                .frame(maxWidth: 100, minHeight: 50)
                .background(Color("MainColor"))
                .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                
                Text("\(route.destinationName)")
                    .font(.headline)
                    .lineLimit(1)
                
                Spacer()
                
                Image(systemName: "chevron.up")
                    .font(.headline)
                    .rotationEffect(.degrees(showHours ? 0 : -180))
                    .padding(.trailing)
            }
            
            if showHours {
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(departures) { departure in
                        HStack(spacing: 0) {
                            Text(departure.timeString)
                                .layoutPriority(1)
                            
                            if departure.symbols != "-" {
                                Text(departure.symbols)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .layoutPriority(0)
                            }
                        }
                    }
                }
                
                VStack(alignment: .leading) {
                    Text("LEGENDA")
                        .font(.footnote.bold())
                    
                    if legend.isEmpty { Text("Brak oznaczeń dla linii na tym przystanku").font(.footnote).foregroundColor(.secondary) }
                    
                    ForEach(legend, id: \.self) { str in
                        HStack {
                            Text(str)
                                .font(.footnote)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                        }
                    }
                }
                .padding([.horizontal, .bottom])
            }
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .shadow(radius: 2, x: 2, y: 2)
        .padding(.horizontal)
        .onAppear {
            getDepartures()
            if busLineName.isEmpty {
                busLineName = dataBaseHelper.getBusLine(busLineId: route.busLineId)?.name ?? ""
            }
        }
        .onTapGesture {
            withAnimation(.spring()) { showHours.toggle() }
        }
    }
    
    func getDepartures() {
        withAnimation(.spring()) { departures = dataBaseHelper.getDeparturesByRouteAndDay(dayTypesQuery: dayType.databaseQuery, routeId: route.id, busStopId: busStop.id) }
    }
}
