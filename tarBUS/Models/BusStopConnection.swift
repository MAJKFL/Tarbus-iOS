//
//  BusStopConnection.swift
//  tarBUS
//
//  Created by Kuba Florek on 11/03/2021.
//

import Foundation
import MapKit

struct BusStopConnection {
    let fromBusStopId: Int
    let toBusStopId: Int
    let distance: String
    let coordsList: String
    
    var coordsArray: [CLLocationCoordinate2D] {
        var locationArray = [CLLocationCoordinate2D]()
        let stringArray = coordsList.components(separatedBy: ",")
        
        for index in stringArray.indices {
            if index % 2 == 0 {
                locationArray.append(CLLocationCoordinate2D(latitude: Double(stringArray[index + 1]) ?? 0, longitude: Double(stringArray[index]) ?? 0))
            }
        }
        
        return locationArray
    }
}
