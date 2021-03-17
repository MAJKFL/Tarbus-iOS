//
//  MapViewWithButtons.swift
//  tarBUS
//
//  Created by Kuba Florek on 11/03/2021.
//

import SwiftUI
import MapKit
import CoreLocation

struct TrackMapView: View {
    let connections: [BusStopConnection]
    let busStops: [BusStop]
    let busStop: BusStop
    
    @State private var selectedBusStop: BusStop?
    @State private var isActive = false
    @State private var mapType = MKMapType.standard
    @State private var isTrackingUser = false
    
    let locationManager = CLLocationManager()
    
    var coordinates: [CLLocationCoordinate2D] {
        var coordinates = [CLLocationCoordinate2D]()
        
        for connection in connections {
            coordinates += connection.coordsArray
        }
        
        return coordinates
    }
    
    var annotations: [BusStopPointAnnotation] {
        let busStopAnnotations = busStops.map { $0.annotation }
        
        for index in busStopAnnotations.indices {
            let annotation = busStopAnnotations[index]
            switch index {
            case 0:
                annotation.image = UIImage(named: "firstMapPoint")
            case busStopAnnotations.count - 1:
                annotation.image = UIImage(named: "lastMapPoint")
            default:
                annotation.image = UIImage(named: "nextMapPoint")
            }
        }
        return busStopAnnotations
    }
    
    var body: some View {
        ZStack {
            NavigationLink("", destination: BusStopView(busStop: selectedBusStop ?? .placeholder, filteredBusLines: []), isActive: $isActive).hidden()
            
            MapView(coordinates: coordinates, annotations: annotations, busStopCoordinate: busStop.location, mapType: mapType, selectedBusStop: $selectedBusStop, isActive: $isActive, isTrackingUser: isTrackingUser)
                .ignoresSafeArea(.all)
            
            HStack {
                Spacer()
                
                VStack(alignment: .trailing, spacing: 0) {
                    Spacer()
                    
                    Button(action: {
                        if mapType == .hybrid {
                            mapType = .standard
                        } else {
                            mapType = .hybrid
                        }
                    }, label: {
                        Image(systemName: "map")
                        .padding(10)
                        .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
                        .clipShape(Circle())
                    })
                    .padding([.horizontal, .bottom])
                    
                    if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
                        Button(action: {
                            isTrackingUser.toggle()
                        }, label: {
                            Image(systemName: isTrackingUser ? "location.fill" : "location")
                                .font(.title)
                                .padding()
                                .background(VisualEffectView(effect: UIBlurEffect(style: .regular)))
                                .clipShape(Circle())
                        })
                        .padding([.horizontal, .bottom])
                    }
                }
                .padding(.bottom)
            }
        }
        .animation(.easeOut)
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
        }
    }
}

