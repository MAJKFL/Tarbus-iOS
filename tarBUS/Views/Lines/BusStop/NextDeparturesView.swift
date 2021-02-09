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
    
    @State private var departures = [NextDeparture]()
    @State private var departuresForNextDay = [NextDeparture]()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(departures) { departure in
                    NavigationLink(destination: DepartureListView(mainDeparture: departure), label: {
                        NextDepartureCellView(departure: departure, isTomorow: false)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
                
                Divider()
                
                ForEach(departuresForNextDay) { departure in
                    NavigationLink(destination: DepartureListView(mainDeparture: departure), label: {
                        NextDepartureCellView(departure: departure, isTomorow: true)
                    })
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding()
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
    let isTomorow: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "bus.fill")
                
                Text(departure.busLineName)
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
                
                if isTomorow {
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
