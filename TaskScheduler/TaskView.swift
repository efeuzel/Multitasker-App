//
//  TaskView.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 2.02.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import SwiftUI
import CoreData

struct TaskView: View {
    
    var task: Task
    @State private var dragAmount = CGSize.zero
    @State private var droppedOnQueue : Int16 = 0
    @EnvironmentObject var appState : AppState
    @GestureState var isDetectingLongPress = false
    
    var body: some View {
        Text(self.task.text ?? "")
            .frame(width: 300, height: 40)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(.systemFill))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(self.droppedOnQueue == 1 || self.droppedOnQueue == 2 ? Color(.systemOrange): Color(.systemGreen))
            )
            .scaleEffect(self.droppedOnQueue > 0 ? 0.6 : 1, anchor: .center)
            .animation(.easeIn)
            .offset(self.dragAmount)
            .zIndex(dragAmount == .zero ? 0 : 1)
            .gesture(
                DragGesture(minimumDistance: 20, coordinateSpace: .global)
                    .onChanged { value in
                        self.dragAmount = value.translation
                        self.appState.movingTask = self.task
                        self.droppedOnQueue = self.droppedOn(location: value.location)
                }
                .onEnded { _ in
                    if self.droppedOnQueue > 0 {
                        self.appState.droppedOnQueue = self.droppedOnQueue
                        if self.droppedOnQueue == 1 {self.appState.showActionSheetTimer = true}
                        if self.droppedOnQueue == 2 {self.appState.showContentViewSheet = true ; self.appState.activeSheet = .locChooser}
                        if self.droppedOnQueue == 3 {self.task.queue = 3}
                        if self.droppedOnQueue == 4 {self.task.queue = 4}
                    }
                    self.dragAmount = CGSize.zero
                    self.droppedOnQueue = 0
                }
        )
    }
    
    func droppedOn(location: CGPoint) -> Int16 {
        if self.appState.waitForLaterQueueFrame.contains(location) {
            return 1
        }
        if self.appState.waitForLocQueueFrame.contains(location) {
            return 2
        }
        if self.appState.doneFrame.contains(location) {
            return 3
        }
        if self.appState.removeFrame.contains(location) {
            return 4
        }
        return 0
    }
}

struct TaskView_Previews: PreviewProvider {
    static var previews: some View {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = Task.init(context: context)
        task.text = "Preview Task"
        
        return TaskView(task: task)
    }
}
