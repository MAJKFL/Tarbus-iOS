//
//  CarrierVersionHelper.swift
//  tarBUS
//
//  Created by Jakub Florek on 29/10/2021.
//

import Foundation

class CompanyVersionHelper: ObservableObject {
    static var url = URL(string: "https://api.tarbus.pl/static/config/available-versions.json")!
}
