//
//  SearchTileViewModel.swift
//  tarBUS
//
//  Created by Kuba Florek on 01/08/2021.
//

import SwiftUI

struct SearchTileViewModel: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
    let isRecomendation: Bool
    let busStop: BusStop?
    let otherDestination: AnyView?
    
    var destination: AnyView {
        if isRecomendation {
            return AnyView(BusStopView(busStop: busStop!, filteredBusLines: []))
        } else {
            return otherDestination!
        }
    }
    
    init(title: String, imageName: String, destination: AnyView) {
        self.title = title
        self.imageName = imageName
        self.otherDestination = destination
        self.isRecomendation = false
        self.busStop = nil
    }
    
    init(title: String, imageName: String, busStop: BusStop) {
        self.title = title
        self.imageName = imageName
        self.busStop = busStop
        self.isRecomendation = true
        self.otherDestination = nil
    }
}
