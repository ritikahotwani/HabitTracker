//
//  HabitCheckBox.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//
import SwiftUI

struct HabitCheckBox: View {
    @State var habit: Habit
    @Binding  var dates: [Date]
    @EnvironmentObject var viewModel: HabitTrackerViewModel

    var body: some View {
        ForEach(dates, id: \.self) { date in
            Button(action: {
                viewModel.toggleHabitCompletion(habit: habit, date: date)
                vibrate(style: .medium)
            }) {
                let isCompleted = habit.completedDatesArray.contains(where: {
                    Calendar.current.isDate($0, inSameDayAs: date)
                })
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .frame(maxWidth: 40)
                    .tint(.black)
                    .foregroundColor(isCompleted ? .black : .gray)
                
                
            }
            .buttonStyle(PlainButtonStyle())
            .contentShape(Rectangle())
        }
    }
}

#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
   return HabitCheckBox(habit:testHabit , dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}

