//
//  MapViewWithButtons.swift
//  tarBUS
//
//  Created by Kuba Florek on 11/03/2021.
//

import SwiftUI
import MapKit

struct TrackMapView: View {
    let connections: [BusStopConnection]
    let busStops: [BusStop]
    let busStop: BusStop
    
    @State private var selectedBusStop: BusStop?
    @State private var isActive = false
    @State private var mapType = MKMapType.standard
    
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
            NavigationLink("", destination: BusStopView(busStop: selectedBusStop ?? .placeholder, filteredBusLines: []), isActive: $isActive).hidden()
            
            MapView(coordinates: coordinates, annotations: annotations, busStopCoordinate: busStop.location, mapType: mapType, selectedBusStop: $selectedBusStop, isActive: $isActive)
        }
        .ignoresSafeArea(.all)
        .navigationBarItems(trailing: Picker(selection: $mapType, label: Image(systemName: "map").padding(10).background(VisualEffectView(effect: UIBlurEffect(style: .regular)).clipShape(Circle())), content: {
            Text("Mapa").tag(MKMapType.standard)
            Text("Satelitarna").tag(MKMapType.hybrid)
        }).pickerStyle(MenuPickerStyle()))
    }
}

