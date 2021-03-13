//
//  BusLineMapView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/03/2021.
//

import SwiftUI
import MapKit

struct BusStopMapView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @State private var selectedBusStop: BusStop?
    @State private var isActive = false
    
    @State private var mapType = MKMapType.standard
    
    @State private var busStops = [BusStop]()
    
    var annotations: [BusStopPointAnnotation] {
        busStops.map({ $0.annotation })
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("", destination: BusStopView(busStop: selectedBusStop ?? .placeholder, filteredBusLines: []), isActive: $isActive).hidden()
                
                MapView(annotations: databaseHelper.getAllBusStops().map({ $0.annotation }), mapType: mapType, selectedBusStop: $selectedBusStop, isActive: $isActive)
            }
            .ignoresSafeArea(.all)
            .navigationBarItems(trailing: Picker(selection: $mapType, label: Image(systemName: "map").padding(10).background(VisualEffectView(effect: UIBlurEffect(style: .regular)).clipShape(Circle())), content: {
                Text("Mapa").tag(MKMapType.standard)
                Text("Satelitarna").tag(MKMapType.hybrid)
            }).pickerStyle(MenuPickerStyle()))
        }
        .onAppear {
            busStops = databaseHelper.getAllBusStops()
        }
    }
}
