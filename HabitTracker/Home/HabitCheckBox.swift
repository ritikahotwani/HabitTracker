//
//  HabitCheckBox.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//
import SwiftUI

struct HabitCheckBox: View {
    @ObservedObject var habit: Habit
    @Binding var dates: [Date]
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            ForEach(dates, id: \.self) { date in
                Button {
                    viewModel.toggleHabitCompletion(habit: habit, date: date)
                    vibrate(style: .medium)
                } label: {
                    let isCompleted = habit.completedDatesArray.contains {
                        Calendar.current.isDate($0, inSameDayAs: date)
                    }

                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)

                        .foregroundColor(
                            isCompleted
                            ? (colorScheme == .dark ? .white : .black)
                            : (colorScheme == .dark ? .gray.opacity(0.7) : .gray)
                        )
                        .frame(width: dayColumnWidth)
                }
                .buttonStyle(.plain)
            }
        }
    }
}


#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
   return HabitCheckBox(habit:testHabit , dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}

