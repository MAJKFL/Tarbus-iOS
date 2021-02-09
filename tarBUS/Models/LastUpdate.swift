//
//  LastUpdate.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/01/2021.
//

import Foundation

struct LastUpdate: Codable {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let min: Int
    
    var formatted: String {
        return "\(day < 10 ? "0\(day)" : "\(day)").\(month < 10 ? "0\(month)" : "\(month)").\(year) \(hour):\(min)"
    }
}
