//
//  date+extensions.swift
//  tarBUS
//
//  Created by Kuba Florek on 30/01/2021.
//

import Foundation

extension Date {
    func get(_ components: Calendar.Component..., calendar: Calendar = Calendar.current) -> DateComponents {
        return calendar.dateComponents(Set(components), from: self)
    }

    func get(_ component: Calendar.Component, calendar: Calendar = Calendar.current) -> Int {
        return calendar.component(component, from: self)
    }
}

extension Date {
    var minutesSinceMidnight: Int {
        let calendar = Calendar.current
        return (calendar.component(.hour, from: self) * 60 + calendar.component(.minute, from: self))
    }
}

