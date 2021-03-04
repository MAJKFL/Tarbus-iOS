//
//  tarBUSWidget.swift
//  tarBUSWidget
//
//  Created by Kuba Florek on 01/03/2021.
//

import WidgetKit
import SwiftUI

struct WidgetModel: TimelineEntry {
    var date: Date
    var busStopName: String
    var busStopId: Int
    var departures: [NextDeparture]
    
    static var placeholder: WidgetModel {
        WidgetModel(date: Date(), busStopName: "Radlna - Budynek Wielofunkcyjny 08", busStopId: 0, departures: [NextDeparture(id: 0, trackId: "", timeString: "12:00", timeInt: 0, boardName: "", busLine: BusLine(id: 0, name: "T10"))])
    }
}

struct dataProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetModel {
        WidgetModel.placeholder
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetModel>) -> Void) {
        let departures = getDepartures()
        let date = getRefreshDate(departures: departures)
        
        let entryData = WidgetModel(date: Date(), busStopName: "Tarnów, Krakowska 02 - Planty", busStopId: 404, departures: departures)
        let timeLine = Timeline(entries: [entryData], policy: .after(date))
        
        completion(timeLine)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetModel) -> Void) {
        let departures = getDepartures()
        
        let entryData = WidgetModel(date: Date(), busStopName: "Tarnów, Krakowska 02 - Planty", busStopId: 404, departures: departures)
        
        completion(entryData)
    }
    
    func getDepartures() -> [NextDeparture] {
        let databaseHelper = DataBaseHelper()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        
        let departuresToday = databaseHelper.getNextDepartures(busStopId: 404, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

        let departuresForNextDay = databaseHelper.getNextDepartures(busStopId: 404, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
        
        let tomorrowDepartures = departuresForNextDay.map { departure in
            departure.forTomorrow
        }
        
        return Array((departuresToday + tomorrowDepartures).prefix(4))
    }
    
    func getRefreshDate(departures: [NextDeparture]) -> Date {
        if departures.isEmpty {
            return Date().midnight.addingTimeInterval(86400)
        } else {
            if departures[0].isTomorrow {
                return Date().addingTimeInterval(86400).midnight.addingTimeInterval(TimeInterval(departures[0].timeInt * 60))
            } else {
                return Date().midnight.addingTimeInterval(TimeInterval(departures[0].timeInt * 60))
            }
        }
    }
}

struct WidgetView: View {
    var data: dataProvider.Entry
    let textGradient = LinearGradient(gradient: Gradient(colors: [.clear, .clear, .clear, Color("GradientColor")]), startPoint: .top, endPoint: .bottom)
    let badgeGradient = LinearGradient(gradient: Gradient(colors: [Color("MainColor"), Color("MainColorGradient")]), startPoint: .topLeading, endPoint: .bottomTrailing)
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(data.busStopName)
                .font(Font.footnote.bold())
                .lineLimit(2)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding([.horizontal, .top], 10)
                .padding(.bottom, 5)
                .background(badgeGradient)
            
            Spacer(minLength: 5)
            
            VStack(spacing: 0) {
                ForEach(data.departures) { departure in
                    HStack(spacing: 0) {
                        Text(departure.busLine.name)
                            .font(.headline)
                            .foregroundColor(Color("MainColor"))
                        
                        Spacer()
                        
                        Text(departure.timeString)
                            .font(.subheadline)
                        
                        if departure.isTomorrow {
                            Image(systemName: "calendar.badge.clock")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                                .padding(.leading, 2)
                        }
                    }
                    .lineLimit(1)
                    .padding(.horizontal, 10)
                    
                    Divider()
                }
                
                Spacer()
            }
            .overlay(textGradient)
        }
    }
}

@main
struct Config: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "Widget", provider: dataProvider()) { data in
            WidgetView(data: data)
        }
        .supportedFamilies([.systemSmall])
        .description(Text("Wyświetla następne odjazdy dla wybranego przystanku"))
        .configurationDisplayName(Text("Następne odjazdy"))
    }
}
