//
//  MapView.swift
//  BucketList
//
//  Created by Kuba Florek on 13/06/2020.
//  Copyright © 2020 kf. All rights reserved.
//

import MapKit
import SwiftUI
import CoreLocation

struct MapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]?
    var annotations: [BusStopPointAnnotation]
    var busStopCoordinate: CLLocationCoordinate2D?
    
    var mapType: MKMapType
    
    @Binding var selectedBusStop: BusStop?
    @Binding var isActive: Bool
    var isTrackingUser: Bool
    
    let locationManager = CLLocationManager()
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        
        var camera: MKMapCamera
        if let busStopCoordinate = busStopCoordinate {
            camera = MKMapCamera(lookingAtCenter: busStopCoordinate, fromDistance: 10000, pitch: 0, heading: 0)
        } else {
            camera = MKMapCamera(lookingAtCenter: CLLocationCoordinate2D(latitude: 50.012416, longitude: 20.988384), fromDistance: 50000, pitch: 0, heading: 0)
        }
        
        if let coordinates = coordinates {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.addOverlay(polyline)
        }
        
        mapView.showsUserLocation = true
        mapView.setCamera(camera, animated: true)
        mapView.addAnnotations(annotations)
        mapView.mapType = mapType
        mapView.showsCompass = false
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
        
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.mapType = mapType
        
        if isTrackingUser {
            view.userTrackingMode = .follow
        } else {
            view.userTrackingMode = .none
        }
        
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
        
        if locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        }
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
            guard let busStopAnnotation = annotation as? BusStopPointAnnotation else { return nil }
            
            let identifier = "Placemark-\(busStopAnnotation.busStop?.id ?? 0)"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                annotationView?.canShowCallout = true
                
                annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                
                annotationView?.centerOffset = CGPoint(x: 0, y: 0)
                
                annotationView?.image = UIImage(named: "mapPoint")
                
                let controller = StackViewGridController()
                
                controller.busStop = busStopAnnotation.busStop
                
                annotationView?.detailCalloutAccessoryView = controller.view
            } else {
                annotationView?.annotation = annotation
            }
            
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
            guard let annotation = view.annotation as? BusStopPointAnnotation else { return }
            
            parent.selectedBusStop = annotation.busStop
            parent.isActive = true
        }
    }
}
