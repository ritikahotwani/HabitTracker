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
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ForEach(dates, id: \.self) { date in
            Button(action: {
                viewModel.toggleHabitCompletion(habit: habit, date: date)
                vibrate(style: .medium)
            }) {
                let isCompleted = habit.completedDatesArray.contains {
                    Calendar.current.isDate($0, inSameDayAs: date)
                }
                
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                    .foregroundColor(
                           isCompleted
                           ? (colorScheme == .dark ? Color.white : Color.black)
                           : (colorScheme == .dark ? Color.gray.opacity(0.7) : Color.gray))
                    .frame(width: 40)
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

