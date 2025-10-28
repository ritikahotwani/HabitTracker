//
//  HabitHeaderView.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//
import SwiftUI
import CoreData

struct HabitHeaderView: View {
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: "flame.fill")
                .foregroundColor(habit.habitColor)
            
            Text(habit.name ?? "Habit")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
                
        }
    }
}
#Preview {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    let habit = Habit(context: context)
    habit.name = "Morning Run"
    habit.priorityColor = UIColor.orange // since it's stored as NSObject
    habit.id = UUID()

    return HabitHeaderView(habit: habit)
}

