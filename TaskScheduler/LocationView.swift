//
//  MapView.swift
//  MapKitDemo
//
//  Created by Efe UZEL on 20.02.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import SwiftUI
import MapKit

struct LocationView: UIViewRepresentable {
    
    @EnvironmentObject var appState : AppState
    @Binding var centerCoordinate: CLLocationCoordinate2D
    @Binding var currentLocationDescription : String
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        if ((self.appState.locationManagerDelegate.locationManager.location) != nil) {
            print(self.appState.locationManagerDelegate.locationManager.location?.coordinate)
            mapView.region = MKCoordinateRegion(center: self.appState.locationManagerDelegate.locationManager.location!.coordinate, latitudinalMeters: 10000, longitudinalMeters: 10000)
        }
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocationView
        var timers: [Timer] = []
        
        init(_ parent: LocationView) {
            self.parent = parent
        }
        
        func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
            parent.centerCoordinate = mapView.centerCoordinate
            
            for timer in self.timers {
                timer.invalidate()
            }
            let centerCLLocation = CLLocation(latitude: mapView.centerCoordinate.latitude, longitude: mapView.centerCoordinate.longitude)
            self.timers.append(Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { _ in
                CLGeocoder().reverseGeocodeLocation(centerCLLocation, completionHandler: { (placemarks, error) in
                    if let currentPlacemarks =  placemarks {
                        self.parent.currentLocationDescription = (currentPlacemarks[0].name ?? "No location description")
                    } else {
                        print(error as Any)
                    }
                })
            }))
        }
    }
}


