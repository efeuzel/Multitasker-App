//
//  ContentView.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 2.02.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import Foundation
import SwiftUI
import CoreData
import MapKit
import UserNotifications

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context //CoreData context
    @EnvironmentObject var appState : AppState
    @State private var newTaskText = ""
    @State private var centerCoordinate = CLLocationCoordinate2D()
    @State private var currentLocationDescription = ""
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dateAdded, ascending: true)],
        predicate: NSPredicate(format: "queue == %@", NSNumber(value: 0))
    ) var activeTasks: FetchedResults<Task>
    
//    let activeTasks = NSFetchRequest<Task>(entityName: "Task")
//    activeTasks.
    
    @FetchRequest(
        entity: Task.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \Task.dateAdded, ascending: false)]
    ) var allTasks: FetchedResults<Task>
    
    var body: some View {
        VStack(spacing: 10) {
            Text("MULTITASKER")
                .italic()
                .bold()
                .foregroundColor(Color(.systemGreen))
                .font(.system(size: 40))
                .padding()
            HStack{
                Spacer(minLength: 10)
                TextField("Enter new task here", text: $newTaskText, onCommit: {self.addTask()} )
                Button(action: {
                    self.addTask()
                }) {Image(systemName: "plus.circle").foregroundColor(Color(.systemGreen))}
                Spacer(minLength: 10)
            }
            .frame(width: 300, height: 40)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGreen)))
            if activeTasks.count > 4 {
                ForEach((1...4), id: \.self) {
                    TaskView(task: self.activeTasks[$0])
                }
                Text("""
                    You have more active tasks than shown.
                    Move some tasks to categories below.
                    """)
                    .font(.subheadline)
                    .foregroundColor(Color(.systemOrange))
                    .multilineTextAlignment(.center)
                .padding()
            } else {
                ForEach(activeTasks) { task in
                    TaskView(task: task)
                }
            }

            Spacer()
            HStack {
                Spacer()
                Circle()
                    .foregroundColor(Color(.secondarySystemFill))
                    .overlay(Image(systemName: "timer").font(.system(size: 25, weight: .regular)))
                    .overlay(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.appState.waitForLaterQueueFrame = geo.frame(in: .global)
                        }
                    })
                    .onTapGesture {
                        self.appState.activeSheet = .waitQueueContent
                        self.appState.showContentViewSheet = true
                }
                Circle()
                    .foregroundColor(Color(.secondarySystemFill))
                    .overlay(Image(systemName: "mappin.and.ellipse").font(.system(size: 25, weight: .regular)))
                    .overlay(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.appState.waitForLocQueueFrame = geo.frame(in: .global)
                        }
                    })
                    .onTapGesture {
                        self.appState.activeSheet = .locationQueueContent
                        self.appState.showContentViewSheet = true
                }
                Spacer()
            }
            .frame(height: 150)
            HStack {
                Circle()
                    .foregroundColor(Color(.secondarySystemFill))
                    .overlay(Image(systemName: "checkmark.square").font(.system(size: 25, weight: .regular)))
                    .overlay(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.appState.doneFrame = geo.frame(in: .global)
                        }
                    })
                    .onTapGesture {
                        self.appState.activeSheet = .completedTasks
                        self.appState.showContentViewSheet = true
                }
                Circle()
                    .foregroundColor(Color(.secondarySystemFill))
                    .overlay(Image(systemName: "xmark.square").font(.system(size: 25, weight: .regular)))
                    .overlay(GeometryReader { geo in
                        Color.clear
                            .onAppear {
                                self.appState.removeFrame = geo.frame(in: .global)
                        }
                    })
            }
            .frame(width: 200, height: 75)
            .padding(.bottom, 10)
        }
        .actionSheet(isPresented: self.$appState.showActionSheetTimer, content: {
            self.actionSheetTimer
        })
            .sheet(isPresented: self.$appState.showContentViewSheet, content: {
                if self.appState.activeSheet == AppState.Sheet.locChooser {
                    LocChooserView(centerCoordinate: self.$centerCoordinate, currentLocationDescription: self.$currentLocationDescription, isVisible: self.$appState.showContentViewSheet)
                        .environmentObject(self.appState)
                }
                else {
                    QueueContentView()
                        .environment(\.managedObjectContext, self.context)
                        .environmentObject(self.appState)                }
            })
    }
    
    var actionSheetTimer: ActionSheet {
        ActionSheet(title: Text("Placing Task in a Queue"), message: Text("Choose waiting time for task"), buttons: [
            .default(Text("Half Hour"), action: {self.actionSheetAction(timeInterval: 5)}),
            .default(Text("One Hour"), action: {self.actionSheetAction(timeInterval: 5)}),
            .default(Text("Four Hours"), action: {self.actionSheetAction(timeInterval: 5)}),
            .default(Text("One Day"), action: {self.actionSheetAction(timeInterval: 5)}),
            .default(Text("Two Days"), action: {self.actionSheetAction(timeInterval: 5)}),
            .default(Text("One Week"), action: {self.actionSheetAction(timeInterval: 604800)}),
            .cancel()
        ])
    }
    
    func actionSheetAction(timeInterval: Double) {
        
        self.appState.movingTask?.dueDate = Date(timeIntervalSinceNow: timeInterval)

        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            // Enable or disable features based on .
        }
        
        let uuidString = self.appState.movingTask?.id?.uuidString
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let content = UNMutableNotificationContent()
        content.title = self.appState.movingTask?.text ?? "A task has moved to your ready queue."
        
        let request = UNNotificationRequest(identifier: uuidString!, content: content, trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                print("Error")
            }
        }
        
        self.appState.movingTask?.queue = 1
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    func addTask() {
        if self.newTaskText != "" {
            self.appState.addTask(self.newTaskText, context: self.context)
            self.newTaskText = ""
        }
        
    }
}
