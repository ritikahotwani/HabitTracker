//
//  HabitList.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//

import SwiftUI

struct HabitList: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @Binding var dates: [Date]

    var body: some View {
        if viewModel.habits.count == 0{
            NoHabitsView()
        }else{
        DateBar(dates: $dates)
            .listRowInsets(
                EdgeInsets(top: 8, leading: 12, bottom: 8, trailing: 12)
            )

        List {
            // ROWS
            ForEach(viewModel.habits) { habit in
                HabitRowItem(habit: habit, dates: $dates)
                    .listRowInsets(
                        EdgeInsets(top: 0, leading: 12, bottom: 0, trailing: 12)
                    )

            }
            .onDelete { indexSet in
                viewModel.deleteHabit(offsets: indexSet)
                vibrate(style: .rigid)
            }
            .onMove { indexSet, newIndex in
                viewModel.habits.move(fromOffsets: indexSet, toOffset: newIndex)

                // persist order
                for (i, habit) in viewModel.habits.enumerated() {
                    habit.sortOrder = Int16(i)
                }
                viewModel.saveContext()

                vibrate(style: .soft)
            }
        }
        .listStyle(.plain)
//        .padding(.horizontal) 
        
    }
}
}


#Preview {
    HabitList(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}
