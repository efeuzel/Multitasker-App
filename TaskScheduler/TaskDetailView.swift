//
//  TaskDetailView.swift
//  TaskScheduler
//
//  Created by Efe UZEL on 8.04.2020.
//  Copyright © 2020 Efe UZEL. All rights reserved.
//

import SwiftUI

struct TaskDetailView: View {
    
    var task: Task
    @EnvironmentObject var appState : AppState
    let dateFormatter = DateFormatter()
    var detailText = ""
    
    var body: some View {
        
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        
        let dateText = dateFormatter.string(from: self.task.dueDate ?? Date())
        
        return
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 1){
                    Text(self.task.text ?? "")
                        .font(.headline)
                        .frame(width: 300, alignment: .leading)
                    if self.task.queue == 1 {
                        Text("Waiting until: \(dateText)")
                    } else if self.task.queue == 2 {
                        Text("Waiting for: \(self.task.dueLocationDescription ?? "")")
                    } else {
                        Text("")
                    }
                }
                
                HStack {
                    Button(action: {
                        self.task.queue = 0
                    }, label: {Image(systemName: "arrow.left.square").font(.system(size: 30, weight: .medium))})
                    Spacer()
                    if self.task.queue != 3 {
                        Button(action: {
                            self.task.queue = 3
                        }, label: {Image(systemName: "checkmark.square").font(.system(size: 30, weight: .medium))})
                        Spacer()
                    }
                    Button(action: {
                        self.task.queue = 4
                    }, label: {Image(systemName: "xmark.square").font(.system(size: 30, weight: .medium))})
                }
            }
            .frame(width: 300)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color(.systemFill))
        )
    }
}

struct TaskDetailView_Previews: PreviewProvider {
    
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let task = Task(context: context)
        task.text = "Dummy Task"
        task.dueLocationDescription = "Ankara, Çankaya"
        task.queue = 2
        return TaskDetailView(task: task)
    }
}
