//
//  CountCard.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI

struct CountCard: View {
    let habit: Habit
    let heading: String
    let count: Int
    
    var body: some View {
        VStack(spacing: 8) {
            Text(heading)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(.secondary)
            
            Text("\(count)")
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(habit.habitColor, lineWidth: 2)
        )
        .shadow(color: habit.habitColor.opacity(0.2), radius: 4, x: 0, y: 2)
    }
}

//#Preview {
//    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
//    testHabit.name = "Ritika"
//    return CountCard(habit: testHabit, heading: "Best Streak", image: "trophy", sentence: "Your personal record!",count: 10)
//    
//}
