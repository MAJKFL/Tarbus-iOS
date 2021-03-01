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
        WidgetModel(date: Date(), busStopName: "Radlna - Budynek Wielofunkcyjny 08", busStopId: 0, departures: [NextDeparture(id: 0, trackId: "", timeString: "12:00", boardName: "", busLine: BusLine(id: 0, name: "T10"))])
    }
}

struct dataProvider: TimelineProvider {
    func placeholder(in context: Context) -> WidgetModel {
        WidgetModel.placeholder
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetModel>) -> Void) {
        let databaseHelper = DataBaseHelper()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        
        let departuresToday = databaseHelper.getNextDepartures(busStopId: 255, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

        let departuresForNextDay = databaseHelper.getNextDepartures(busStopId: 255, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
        
        let departures = Array((departuresToday + departuresForNextDay).prefix(3))
        
        print(departures)
        
        let entryData = WidgetModel(date: Date(), busStopName: "Radlna - Budynek Wielofunkcyjny 08", busStopId: 255, departures: departures)
        
        let timeLine = Timeline(entries: [entryData], policy: .never)
        
        completion(timeLine)
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WidgetModel) -> Void) {
        let databaseHelper = DataBaseHelper()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        
        let departuresToday = databaseHelper.getNextDepartures(busStopId: 255, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

        let departuresForNextDay = databaseHelper.getNextDepartures(busStopId: 255, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
        
        let departures = Array((departuresToday + departuresForNextDay).prefix(3))
        
        print(departures)
        
        let entryData = WidgetModel(date: Date(), busStopName: "Radlna - Budynek Wielofunkcyjny 08", busStopId: 255, departures: departures)
        
        completion(entryData)
    }
}

struct WidgetView: View {
    var data: dataProvider.Entry
    
    var body: some View {
        VStack {
            ForEach(data.departures) { departure in
                Text(departure.busLine.name)
            }
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
