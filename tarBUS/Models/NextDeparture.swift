//
//  nextDeparture.swift
//  tarBUS
//
//  Created by Kuba Florek on 08/02/2021.
//

import Foundation

struct NextDeparture: Identifiable {
    let id: Int
    let trackId: String
    let timeString: String
    let timeInt: Int
    let boardName: String
    
    let busLine: BusLine
    
    var isTomorrow = false
    
    var forTomorrow: NextDeparture {
        var tomorrowDeparture = self
        tomorrowDeparture.isTomorrow = true
        return tomorrowDeparture
    }
}

struct NextDepartureDay: Identifiable {
    let id = UUID()
    let date: Date
    let departures: [NextDeparture]
}
