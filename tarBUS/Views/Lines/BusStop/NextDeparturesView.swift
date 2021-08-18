//
//  NextDeparturesView.swift
//  tarBUS
//
//  Created by Kuba Florek on 01/02/2021.
//

import SwiftUI

struct NextDeparturesView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @State private var days = [NextDepartureDay]()
    @State var filteredBusLines: [BusLine]
    
    let busStop: BusStop
    
    var filteredDays: [NextDepartureDay] {
        if filteredBusLines.isEmpty { return days }
        
        var newDays = [NextDepartureDay]()
        for day in days {
            let departures = day.departures
            let filteredDepartures = departures.filter({ filteredBusLines.contains($0.busLine) })
            let newDay = NextDepartureDay(date: day.date, departures: filteredDepartures)
            newDays.append(newDay)
        }

        return newDays
    }
    
    var allDepartures: [NextDeparture] {
        var departures = [NextDeparture]()
        for day in days {
            for departure in day.departures {
                departures.append(departure)
            }
        }
        
        return departures
    }
    
    var body: some View {
        VStack {
            Text(busStop.name)
                .bold()
                .padding(.top)
            
            FilterView(filteredBusLines: $filteredBusLines, allDepartures: allDepartures)
            
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(filteredDays) { day in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(day.date, style: .date)
                                .foregroundColor(.secondary)
                            
                            Divider()
                                .onAppear {
                                    if !days.contains(where: { $0.date == day.date.addingTimeInterval(86400) }) {
                                        getDay(forDate: day.date.addingTimeInterval(86400))
                                    }
                                }
                        }
                        
                        if day.departures.isEmpty {
                            Text("Brak odjazdów")
                        }
                        
                        ForEach(day.departures) { departure in
                            NavigationLink(destination: DepartureListView(mainDeparture: departure, busStop: busStop)) {
                                NextDepartureCellView(departure: departure)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .id("\(day.date)\(departure.id)")
                        }
                    }
                    
//                    if !(filteredDepartureDays).isEmpty {
//
//                    } else {
//                        VStack(spacing: 20) {
//                            Image("noDepartures")
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: UIScreen.main.bounds.width - 100)
//
//                            Text("Niestety, nie znaleźliśmy odjazdów w najbliższym czasie")
//                                .font(.headline)
//                                .multilineTextAlignment(.center)
//                                .foregroundColor(.secondary)
//
//                            Button(action: {
//                                withAnimation(.easeIn) { currentView = 2 }
//                            }, label: {
//                                Text("Zobacz pełny rozkład jazdy")
//                                    .font(.headline)
//                                    .foregroundColor(.white)
//                                    .padding()
//                                    .background(Color("MainColor"))
//                                    .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
//                            })
//                            .buttonStyle(PlainButtonStyle())
//                        }
//                        .padding(.horizontal)
//                    }
                }
                .padding()
                .padding(.bottom, 25)
            }
            .onAppear {
                if days.isEmpty {
                    getDay()
                }
            }
        }
    }
    
    func getDay() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        let departures = databaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)
        let day = NextDepartureDay(date: date, departures: departures)
        
        days.append(day)
    }
    
    func getDay(forDate date: Date) {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = date
        let departures = databaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: 0)
        let day = NextDepartureDay(date: date, departures: departures)
        
        days.append(day)
    }
}

fileprivate struct NextDepartureCellView: View {
    let departure: NextDeparture
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "bus.fill")
                
                Text(departure.busLine.name)
            }
            .font(.headline.weight(.bold))
            .foregroundColor(.white)
            .frame(maxWidth: 100, minHeight: 50, maxHeight: .infinity)
            .background(Color("MainColor"))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            Text(departure.boardName)
            
            Spacer()
            
            VStack {
                Text(departure.timeString)
                    .fontWeight(.bold)
                    .padding(.trailing)
            }
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .shadow(radius: 2, x: 2, y: 2)
    }
}

fileprivate struct FilterView: View {
    @State private var showPicker = false
    @Binding var filteredBusLines: [BusLine]
    
    let allDepartures: [NextDeparture]
    
    var busLines: [BusLine] {
        let allBusLines = allDepartures.map { departure in
            departure.busLine
        }
        
        return allBusLines.removeDuplicates().sorted(by: { $0.id < $1.id })
    }
    
    var isHidden: Bool {
        busLines.count <= 1
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        if isHidden {
            EmptyView()
        } else {
            HStack(alignment: .midFilteredBusesAndButton) {
                if !filteredBusLines.isEmpty || showPicker {
                VStack {
                    LazyVGrid(columns: columns) {
                        ForEach(filteredBusLines) { busLine in
                            HStack {
                                Text(busLine.name)
                                
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .frame(minWidth: 0)
                            .padding(10)
                            .background(Color("lightGray"))
                            .clipShape(Capsule())
                            .id(busLine.id)
                            .onTapGesture {
                                withAnimation(Animation.easeOut.speed(2)) { filteredBusLines.removeAll(where: { $0 == busLine }) }
                            }
                        }
                    }
                    .alignmentGuide(.midFilteredBusesAndButton) { d in d[VerticalAlignment.center] }
                    
                    if showPicker {
                        Divider()
                        
                        LazyVGrid(columns: columns) {
                            ForEach(busLines) { busLine in
                                if !filteredBusLines.contains(busLine) {
                                    HStack {
                                        Text(busLine.name)
                                        
                                        Image(systemName: "plus.circle.fill")
                                            .foregroundColor(.gray)
                                    }
                                    .frame(minWidth: 0)
                                    .padding(10)
                                    .background(Color("lightGray"))
                                    .clipShape(Capsule())
                                    .id(busLine.id)
                                    .onTapGesture {
                                        if !filteredBusLines.contains(busLine) {
                                            withAnimation(Animation.easeOut.speed(2)) {
                                                filteredBusLines.append(busLine)
                                                filteredBusLines.sort(by: { $0.id < $1.id })
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(width: UIScreen.main.bounds.width / 3 * 2)
                }
                
                Button(action: {
                    withAnimation(Animation.easeOut.speed(2)) { showPicker.toggle() }
                }, label: {
                    Label("Filtruj", systemImage: "line.horizontal.3.decrease")
                        .font(.body)
                })
                .alignmentGuide(.midFilteredBusesAndButton) { d in d[VerticalAlignment.center] }
            }
            .font(.footnote)
        }
    }
}
