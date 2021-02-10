//
//  Destination.swift
//  tarBUS
//
//  Created by Kuba Florek on 23/01/2021.
//

import Foundation

struct BusStop: Identifiable, Codable {
    let id: Int
    let name: String
    let searchName: String
    let longitude: Double
    let latitude: Double
    let destination: String
    
    var userName: String?
}
