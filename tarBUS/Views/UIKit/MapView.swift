//
//  MapView.swift
//  BucketList
//
//  Created by Kuba Florek on 13/06/2020.
//  Copyright © 2020 kf. All rights reserved.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]
    var annotations: [BusStopPointAnnotation]
    
    @Binding var selectedBusStop: BusStop?
    
    func makeUIView(context: Context) -> MKMapView {
        let camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: 50.012461, longitude: 20.988400), fromDistance: 50000, pitch: 0, heading: 0)
        
        let mapView = MKMapView()
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        mapView.setCamera(camera, animated: true)
        mapView.addAnnotations(annotations)
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            // this is our unique identifier for view reuse
            let identifier = "Placemark"

            // attempt to find a cell we can recycle
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                // we didn't find one; make a new one
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

                // allow this to show pop up information
                annotationView?.canShowCallout = true
                
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
                annotationView?.centerOffset = CGPoint(x: 0, y: 0)
                
                annotationView?.image = UIImage(named: "mapPoint")
            } else {
                // we have a view to reuse, so give it the new annotation
                annotationView?.annotation = annotation
            }
            
            // whether it's a new view or a recycled one, send it back
            return annotationView
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

            if let routePolyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: routePolyline)
                renderer.strokeColor = UIColor(Color("MainColor"))
                renderer.lineWidth = 7
                return renderer
            }

            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let busStopAnnotation = view.annotation as? BusStopPointAnnotation else { return }
            
            parent.selectedBusStop = busStopAnnotation.busStop
        }
    }
}
