//
//  BusLine.swift
//  tarBUS
//
//  Created by Kuba Florek on 21/01/2021.
//

import Foundation

struct BusLine: Identifiable, Codable, Equatable {
    let id: Int
    let name: String
    let versionID: Int
    
    static func ==(lhs: BusLine, rhs: BusLine) -> Bool {
        return lhs.id == rhs.id
    }
}
