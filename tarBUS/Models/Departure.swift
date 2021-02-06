//
//  Departure.swift
//  tarBUS
//
//  Created by Kuba Florek on 26/01/2021.
//

import Foundation

struct Departure: Identifiable, Equatable {
    let id: Int
    let busStopId: Int
    let trackId: String
    let busLineId: Int
    let busStopLp: Int
    let timeInMin: Int
    let timeString: String
    let symbols: String
    let routeId: Int
    let legend: String
    let busLineName: String
    let dayId: Int
    let boardName: String?
    
    let route: Route?
    
    static func ==(lhs: Departure, rhs: Departure) -> Bool {
        return lhs.id == rhs.id
    }
}
