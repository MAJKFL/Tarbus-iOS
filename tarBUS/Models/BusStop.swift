//
//  Destination.swift
//  tarBUS
//
//  Created by Kuba Florek on 23/01/2021.
//

import Foundation
import MapKit

struct BusStop: Identifiable, Codable {
    let id: Int
    let name: String
    let searchName: String
    let longitude: Double
    let latitude: Double
    let destination: String
    
    var userName: String?
    
    var annotation: BusStopPointAnnotation {
        let newAnnotation = BusStopPointAnnotation()
        newAnnotation.title = name
        newAnnotation.coordinate.latitude = latitude
        newAnnotation.coordinate.longitude = longitude
        newAnnotation.busStop = self
        return newAnnotation
    }
    
    var location: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    static var placeholder: BusStop {
        BusStop(id: 0, name: "", searchName: "", longitude: 0, latitude: 0, destination: "")
    }
}

class BusStopPointAnnotation: MKPointAnnotation {
    var busStop: BusStop?
    var image: UIImage?
}
