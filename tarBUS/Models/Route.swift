//
//  Route.swift
//  tarBUS
//
//  Created by Kuba Florek on 26/01/2021.
//

import Foundation

struct Route: Identifiable {
    let id: Int
    let destinationName: String
    let busLineId: Int
    let description: String
    
    var towns: [String] { description.components(separatedBy: ", ") }
}
