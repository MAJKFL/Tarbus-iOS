//
//  BusStopParam+Extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 20/10/2021.
//

import Foundation

extension BusStopParam {
    convenience init(busStop: BusStop) {
        self.init(identifier: "\(busStop.id)", display: busStop.name)
        self.name = busStop.name
        self.number = NSNumber(value: busStop.id)
    }
}
