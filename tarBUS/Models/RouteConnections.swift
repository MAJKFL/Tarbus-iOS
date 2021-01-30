//
//  RouteConnections.swift
//  tarBUS
//
//  Created by Kuba Florek on 26/01/2021.
//

import Foundation

struct RouteConnections: Identifiable {
    let id: Int
    let routeId: Int
    let isOptional: Int
    let lp: Int
    let busStopId: Int
}
