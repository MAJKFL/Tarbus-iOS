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
        WidgetModel(date: Date(), busStopName: "Radlna - Budynek Wielofunkcyjny 08", busStopId: 0, departures: [NextDeparture(id: 0, trackId: "", timeString: "12:00", timeInt: 0, boardName: "", busLine: BusLine(id: 0, name: "T10"))])
    }
}
