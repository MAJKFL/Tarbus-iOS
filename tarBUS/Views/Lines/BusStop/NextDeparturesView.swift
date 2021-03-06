//
//  NextDeparturesView.swift
//  tarBUS
//
//  Created by Kuba Florek on 01/02/2021.
//

import SwiftUI

struct NextDeparturesView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    let busStop: BusStop
    @State var filteredBusLines: [BusLine]
    
    @State private var departures = [NextDeparture]()
    @State private var departuresForNextDay = [NextDeparture]()
    
    var filteredDepartures: [NextDeparture] {
        if filteredBusLines.isEmpty { return departures }
        return departures.filter({ filteredBusLines.contains($0.busLine) })
    }
    
    var filteredDeparturesForNextDay: [NextDeparture] {
        if filteredBusLines.isEmpty { return departuresForNextDay }
        return departuresForNextDay.filter({ filteredBusLines.contains($0.busLine) })
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                FilterView(filteredBusLines: $filteredBusLines, allDepartures: departures + departuresForNextDay)
                
                ForEach(filteredDepartures) { departure in
                    NavigationLink(destination: DepartureListView(mainDeparture: departure, busStop: busStop), label: {
                        NextDepartureCellView(departure: departure, isTomorrow: false)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .id("\(departure.id)-today")
                }
                
                Divider()
                
                ForEach(filteredDeparturesForNextDay) { departure in
                    NavigationLink(destination: DepartureListView(mainDeparture: departure, busStop: busStop), label: {
                        NextDepartureCellView(departure: departure, isTomorrow: true)
                    })
                    .buttonStyle(PlainButtonStyle())
                    .id("\(departure.id)-yesterday")
                }
            }
            .padding()
            .padding(.bottom, 25)
        }
        .onAppear {
            if departures.isEmpty {
                getDepartures()
            }
        }
    }
    
    func getDepartures() {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        
        departures = databaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

        departuresForNextDay = databaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
    }
}

fileprivate struct NextDepartureCellView: View {
    let departure: NextDeparture
    let isTomorrow: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "bus.fill")
                
                Text(departure.busLine.name)
            }
            .font(Font.headline.weight(.bold))
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
                
                if isTomorrow {
                    Text("Jutro")
                        .font(.footnote)
                        .foregroundColor(Color("MainColor"))
                }
            }
        }
        .background(Color("lightGray"))
        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
        .shadow(radius: 5, x: 5, y: 5)
    }
}

fileprivate struct FilterView: View {
    @Binding var filteredBusLines: [BusLine]
    let allDepartures: [NextDeparture]
    
    @State private var showPicker = false
    
    @Namespace private var animation
    
    var busLines: [BusLine] {
        let allBusLines = allDepartures.map { departure in
            departure.busLine
        }
        
        return allBusLines.removeDuplicates().sorted(by: { $0.id < $1.id })
    }
    
    var isDisabled: Bool {
        busLines.count <= 1
    }
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        VStack {
            Button(action: {
                withAnimation(Animation.easeOut.speed(2)) { showPicker.toggle() }
            }, label: {
                HStack {
                    Text("Filtruj")
                    
                    Image(systemName: "line.horizontal.3.decrease")
                }
                .font(.body)
            })
            .disabled(isDisabled)
            
            if !isDisabled {
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
                        .matchedGeometryEffect(id: busLine.id, in: animation)
                        .onTapGesture {
                            withAnimation(Animation.easeOut.speed(2)) { filteredBusLines.removeAll(where: { $0 == busLine }) }
                        }
                    }
                }
            }
            
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
                            .matchedGeometryEffect(id: busLine.id, in: animation)
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
        .font(.footnote)
    }
}
