//
//  LocChooserView.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 25.02.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import SwiftUI
import CoreLocation

struct LocChooserView: View {
    
    @EnvironmentObject var appState : AppState
    @Binding var centerCoordinate : CLLocationCoordinate2D
    @Binding var currentLocationDescription : String
    @Binding var isVisible : Bool
    
    var body: some View {
        ZStack{
            LocationView(centerCoordinate: $centerCoordinate, currentLocationDescription: $currentLocationDescription)
            Image(systemName: "plus")
            VStack(spacing: 10) {
                Text(currentLocationDescription)
                Button(action: {
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.alert, .sound]) { granted, error in
                        // Enable or disable features based on authorization.
                    }
                    let region = CLCircularRegion(center: self.centerCoordinate, radius: self.appState.regionRadius, identifier: self.appState.movingTask?.id?.uuidString ?? "")
                    region.notifyOnEntry = true
                    region.notifyOnExit = false
                    self.appState.locationManagerDelegate.locationManager.startMonitoring(for: region)
                    
                    self.appState.movingTask?.queue = 2
                    self.appState.movingTask?.region = region
                    self.appState.movingTask?.dueLocationDescription = self.currentLocationDescription
                    self.appState.movingTask?.dueLatitude = self.centerCoordinate.latitude
                    self.appState.movingTask?.dueLongitude = self.centerCoordinate.longitude
                    (UIApplication.shared.delegate as! AppDelegate).saveContext()
                    self.isVisible = false
                }, label: {
                    Text("Mark This Location")
                        //.foregroundColor(Color(.))
                        .frame(width: 250)
                })
                Button(action: {
                    self.isVisible = false
                    }, label: {
                        Text("Cancel")
                            .foregroundColor(Color(.systemOrange))
                })
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10)
            .foregroundColor(Color(.tertiarySystemBackground)))
            .offset(y: 200)
            
        }
            .onAppear {
                self.appState.locationManagerDelegate.locationManager.requestAlwaysAuthorization()
                self.appState.locationManagerDelegate.locationManager.requestLocation()
        }
        .onDisappear {
        }
    }
}
