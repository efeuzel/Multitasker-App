//
//  LocationManagerDelgate.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 25.03.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import Foundation
import CoreLocation
import UserNotifications
import CoreData
import SwiftUI


public class LocationManagerDelegate: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var userCoordinate2D = CLLocationCoordinate2D()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override  init() {
        super.init()
        self.locationManager.delegate = self
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        
        print("entered region")
        
        let center = UNUserNotificationCenter.current()
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let allTasks = NSFetchRequest<Task>(entityName: "Task")
        
        do {
            let fetchedResults = try context.fetch(allTasks)
            for task in fetchedResults {
                if task.queue == 2  {
                    print("Region is matched with task: \(task.text ?? "NO TITLE")")
                    if task.region == region {
                        let content = UNMutableNotificationContent()
                        content.title = "You can perfom a task here"
                        content.body = "You have scheduled \"\(task.text ?? "a task")\" to perfom at \(task.dueLocationDescription ?? "this location")."
                        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
                        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                        center.add(request)
                    }
                }
            }
        }
        catch let error as NSError {
            print(error.description)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userCoordinate2D = manager.location!.coordinate
        print("User is at \(userCoordinate2D.latitude) \(userCoordinate2D.longitude)")
        let allTasks = NSFetchRequest<Task>(entityName: "Task")
        do {
            let fetchedResults = try context.fetch(allTasks)
            for task in fetchedResults {
                if (task.queue == 2) {
                    if (task.region as! CLCircularRegion).contains(userCoordinate2D) {
                        task.queue = 0
                    }
                }
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        catch let error as NSError {
            print(error.description)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
}



