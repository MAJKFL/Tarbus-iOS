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
    let boardName: String
    
    let busLine: BusLine
}
