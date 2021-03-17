//
//  BusLineMapView.swift
//  tarBUS
//
//  Created by Kuba Florek on 13/03/2021.
//

import SwiftUI
import MapKit
import CoreLocation

struct BusStopMapView: View {
    @ObservedObject var databaseHelper = DataBaseHelper()
    @State private var selectedBusStop: BusStop?
    @State private var isActive = false
    @State private var isTrackingUser = false
    
    @State private var mapType = MKMapType.standard
    
    @State private var busStops = [BusStop]()
    
    let locationManager = CLLocationManager()
    
    var annotations: [BusStopPointAnnotation] {
        let busStopAnnotations = busStops.map { $0.annotation }
        
        for annotation in busStopAnnotations {
            annotation.image = UIImage(named: "nextMapPoint")
        }
        return busStopAnnotations
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("", destination: BusStopView(busStop: selectedBusStop ?? .placeholder, filteredBusLines: []), isActive: $isActive).hidden()
                
                MapView(annotations: annotations, mapType: mapType, selectedBusStop: $selectedBusStop, isActive: $isActive, isTrackingUser: isTrackingUser)
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
        }
        .animation(.easeOut)
        .onAppear {
            if locationManager.authorizationStatus == .notDetermined {
                locationManager.requestWhenInUseAuthorization()
            }
            
            if busStops.isEmpty {
                DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + 0.1) {
                    busStops = databaseHelper.getAllBusStops()
                }
            }
        }
    }
}
