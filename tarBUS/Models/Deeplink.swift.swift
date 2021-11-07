//
//  Deeplink.swift.swift
//  tarBUS
//
//  Created by Jakub Florek on 07/11/2021.
//

import Foundation

struct Deeplink: Identifiable {
    var id = UUID()
    var busStop: BusStop
    
    var filteredBusLines = [BusLine]()
}
