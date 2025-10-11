//
//  WeeklyProgress.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//
import SwiftUI

struct WeeklyProgress: View {
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundColor(.primary)
            
            if let weekData = habit.weeklyProgress {
                MonthlyProgressBar(
                    habit: habit,
                    progress: weekData.progress,
                    startDate: weekData.start,
                    endDate: weekData.end
                )
            }
        }
        .padding()
    }
}

#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
    let calendar = Calendar.current
    testHabit.completedDatesArray = [
        calendar.date(byAdding: .day, value: -1, to: Date())!,
        calendar.date(byAdding: .day, value: -3, to: Date())!
    ]
    return WeeklyProgress(habit: testHabit)
}
