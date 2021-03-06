//
//  DataProvider.swift
//  tarBUSWidgetExtension
//
//  Created by Kuba Florek on 06/03/2021.
//

import Foundation
import WidgetKit

struct DataProvider: IntentTimelineProvider {
    typealias Entry = WidgetModel
    typealias Intent = SelectBusStopIntent
    
    func placeholder(in context: Context) -> WidgetModel {
        .placeholder
    }
    
    func getSnapshot(for configuration: SelectBusStopIntent, in context: Context, completion: @escaping (WidgetModel) -> Void) {
        let departures = getDepartures(nil)
        
        let entryData = WidgetModel(date: Date(), busStopName: configuration.busStop?.name ?? "", busStopId: configuration.busStop?.number as? Int, departures: departures)
        
        completion(entryData)
    }
    
    func getTimeline(for configuration: SelectBusStopIntent, in context: Context, completion: @escaping (Timeline<WidgetModel>) -> Void) {
        let departures = getDepartures(configuration.busStop?.number as? Int)
        let date = getRefreshDate(departures: departures)
        
        let entryData = WidgetModel(date: Date(), busStopName: configuration.busStop?.name ?? "", busStopId: configuration.busStop?.number as? Int, departures: departures)
        let timeLine = Timeline(entries: [entryData], policy: .after(date))
        
        completion(timeLine)
    }
    
    func getDepartures(_ id: Int?) -> [NextDeparture] {
        let databaseHelper = DataBaseHelper()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        
        let date = Date()
        
        if let id = id {
            let departuresToday = databaseHelper.getNextDepartures(busStopId: id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date)), startFromTime: Date().minutesSinceMidnight)

            let departuresForNextDay = databaseHelper.getNextDepartures(busStopId: id, dayTypes: databaseHelper.getCurrentDayType(currentDateString: formatter.string(from: date.addingTimeInterval(86400))), startFromTime: 0)
            
            let tomorrowDepartures = departuresForNextDay.map { departure in
                departure.forTomorrow
            }
            return Array((departuresToday + tomorrowDepartures).prefix(4))
        }
        return []
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
