//
//  AppState.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 22.02.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import CoreLocation
import UserNotifications

class AppState : ObservableObject {
    
    @Published var waitForLocQueueFrame = CGRect()
    @Published var waitForLaterQueueFrame = CGRect()
    @Published var removeFrame = CGRect()
    @Published var doneFrame = CGRect()
    @Published var movingTask : Task?
    @Published var showActionSheetTimer: Bool = false
    @Published var showContentViewSheet: Bool = false
    @Published var droppedOnQueue: Int16 = 0
    @Published var activeSheet : Sheet = .locChooser
    @Published var regionRadius = 50000.0//250.0
    @Published var locationManagerDelegate = LocationManagerDelegate()
    
    func addTask(_ taskText : String, context: NSManagedObjectContext) {
        let newTask = Task(context: context)
        newTask.id = UUID()
        newTask.text = taskText
        newTask.queue = 0
        newTask.dateAdded = Date()
        do {
            try context.save()
        } catch {
            print(error)
        }
    }
    
    enum Sheet {
        case locChooser
        case locationQueueContent
        case waitQueueContent
        case completedTasks
    }
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    func refresh() {
        
        print("refresh triggered by sceneWillEnterForeground")
        
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        
        let allTasks = NSFetchRequest<Task>(entityName: "Task")
        do {
            let fetchedResults = try context.fetch(allTasks)
            for task in fetchedResults {
                if task.queue == 1 {
                    if task.dueDate ?? Date() <= Date() {
                        task.queue = 0
                    }
                }
                
                if task.queue == 2  {
                    locationManagerDelegate.locationManager.requestLocation() //logic is handled at the delegate method
                } else {
                    if let region = task.region {
                        locationManagerDelegate.locationManager.stopMonitoring(for: region as! CLCircularRegion) //stop region monitoring for all tasks that have a region but not in location queue anymore.
                    }
                        
                }
            }
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
        catch let error as NSError {
            print(error.description)
        }
    }
    
    
}
