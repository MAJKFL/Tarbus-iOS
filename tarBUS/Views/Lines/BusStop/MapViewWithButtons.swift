//
//  MapViewWithButtons.swift
//  tarBUS
//
//  Created by Kuba Florek on 11/03/2021.
//

import SwiftUI
import MapKit

struct MapViewWithButtons: View {
    let connections: [BusStopConnection]
    let busStops: [BusStop]
    let busStop: BusStop
    
    var coordinates: [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        for connection in connections {
            coordinates += connection.coordsArray
        }
        
        return coordinates
    }
    
    var annotations: [BusStopPointAnnotation] {
        busStops.map { $0.annotation }
    }
    
    var body: some View {
        ZStack {
            MapView(coordinates: coordinates, annotations: annotations, busStopCoordinate: busStop.location)
        }
        .ignoresSafeArea(.all)
    }
}

