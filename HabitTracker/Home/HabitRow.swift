//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI

struct HabitRowItem: View {
    @ObservedObject var habit: Habit
    @Binding var dates: [Date]
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let nameWidth = totalWidth * 0.45
            let dayWidth = (totalWidth * 0.55) / CGFloat(dates.count)

            HStack(spacing: 0) {

                // Habit name (adaptive)
                HabitName(habit: habit)
                    .frame(width: nameWidth, alignment: .leading)

                // Date checkboxes
                HStack(spacing: 0) {
                    ForEach(dates, id: \.self) { date in
                        let isCompleted = habit.completedDatesArray.contains {
                            Calendar.current.isDate($0, inSameDayAs: date)
                        }

                        Button {
                            viewModel.toggleHabitCompletion(habit: habit, date: date)
                            vibrate(style: .medium)
                        } label: {
                            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 16, height: 16)
                                .foregroundColor(
                                    isCompleted
                                    ? (colorScheme == .dark ? .white : .black)
                                    : .gray
                                )
                                .frame(width: dayWidth)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .frame(height: 36)   // 👈 compact row height
    }
}







