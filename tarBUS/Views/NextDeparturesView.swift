//
//  NextDeparturesView.swift
//  tarBUS
//
//  Created by Kuba Florek on 01/02/2021.
//

import SwiftUI

struct NextDeparturesView: View {
    @ObservedObject var dataBaseHelper = DataBaseHelper()
    let busStop: BusStop
    
    @State private var departures = [Departure]()
    @State private var departuresForNextDay = [Departure]()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ForEach(departures) { departure in
                    nextDepartureCellView(departure: departure, isTomorow: false)
                }
                
                Divider()
                    .padding()
                
                ForEach(departuresForNextDay) { departure in
                    nextDepartureCellView(departure: departure, isTomorow: true)
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
        
        departures = dataBaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: dataBaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

        departuresForNextDay = dataBaseHelper.getNextDepartures(busStopId: busStop.id, dayTypes: dataBaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
    }
}

struct nextDepartureCellView: View {
    let departure: Departure
    let isTomorow: Bool
    
    var body: some View {
        HStack {
            HStack {
                Image(systemName: "bus.fill")
                
                Text(departure.busLineName)
            }
            .font(Font.headline.weight(.bold))
            .foregroundColor(.white)
            .frame(maxWidth: 100, minHeight: 50)
            .background(Color("MainColor"))
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
            
            Text(departure.boardName ?? "")
            
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
