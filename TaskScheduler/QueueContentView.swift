//
//  WaitQueueContentView.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 8.04.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import SwiftUI

struct QueueContentView: View {
    
    @EnvironmentObject var appState : AppState
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dateAdded, ascending: false)]
        ,predicate: NSPredicate(format: "queue == %@", NSNumber(value: 1))
    ) var tasksInWaitQueue: FetchedResults<Task>
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dateAdded, ascending: false)]
        ,predicate: NSPredicate(format: "queue == %@", NSNumber(value: 2))
    ) var tasksInLocQueue: FetchedResults<Task>
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dateAdded, ascending: false)]
        ,predicate: NSPredicate(format: "queue == %@", NSNumber(value: 3))
    ) var completedTasks: FetchedResults<Task>
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                if self.appState.activeSheet == .waitQueueContent {
                    Text("Waiting for a Later Time")
                        .font(.headline)
                        .padding()
                    if self.tasksInWaitQueue.count > 0 {
                        ForEach(self.tasksInWaitQueue){ task in
                            TaskDetailView(task: task)
                        }
                    } else {
                        Text("There are no tasks waiting for a later time.")
                    }
                    
                }
                if self.appState.activeSheet == .locationQueueContent {
                    Text("Waiting for a Specific Location")
                        .font(.headline)
                        .padding()
                    if self.tasksInLocQueue.count > 0 {
                        ForEach(self.tasksInLocQueue){ task in
                            TaskDetailView(task: task)
                        }
                    } else {
                        Text("There are no tasks waiting for a specific location.")
                    }
                }
                if self.appState.activeSheet == .completedTasks {
                    Text("Completed")
                        .font(.headline)
                        .padding()
                    if self.completedTasks.count > 0 {
                        ForEach(self.completedTasks){ task in
                            TaskDetailView(task: task)
                        }
                    }
                    else {
                        Text("There are no completed tasks.")
                    }
                }
                
            }
        }
    }
}

