//
//  WidgetModel.swift
//  tarBUSWidgetExtension
//
//  Created by Kuba Florek on 06/03/2021.
//

import Foundation
import WidgetKit

struct WidgetModel: TimelineEntry {
    var date: Date
    var busStopName: String
    var busStopId: Int?
    var departures: [NextDeparture]
    
    static var placeholder: WidgetModel {
        WidgetModel(date: Date(), busStopName: "Radlna - Budynek Wielofunkcyjny 08", busStopId: 255, departures: [])
    }
    
    static var snapshotPlaceholder: WidgetModel {
        WidgetModel(date: Date(), busStopName: "Tarnów, Krakowska 02 - Planty", busStopId: 404, departures: [
            NextDeparture(id: 1, trackId: "", timeString: "11:50", timeInt: 0, boardName: "Łękawka Kościół", busLine: BusLine(id: 1, name: "T08")),
            NextDeparture(id: 2, trackId: "", timeString: "11:59", timeInt: 0, boardName: "Kochanowskiego Chyszowska", busLine: BusLine(id: 2, name: "T24")),
            NextDeparture(id: 3, trackId: "", timeString: "12:20", timeInt: 0, boardName: "Krakowska Planty", busLine: BusLine(id: 3, name: "T39")),
            NextDeparture(id: 4, trackId: "", timeString: "12:25", timeInt: 0, boardName: "Kłokowa", busLine: BusLine(id: 4, name: "T25"))
        ])
    }
}
