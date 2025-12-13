//
//  HabitRow.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI


struct HabitRow: View {
    @Binding  var dates: [Date]
    @EnvironmentObject var viewModel: HabitTrackerViewModel
//    @State private var showDeleteAlert = false
//    @State private var pendingDeleteIndex: IndexSet?

    var body: some View {
        ForEach(viewModel.habits) { habit in
            HStack(spacing: 8){
                HabitName(habit: habit)
                    
                Spacer(minLength: 4)
                HabitCheckBox(habit: habit, dates: $dates)
            }
            .padding()
            .listRowInsets(EdgeInsets())
        }
        
        .onDelete { indexSet in
//            pendingDeleteIndex = indexSet
//            showDeleteAlert = true
            viewModel.deleteHabit(offsets: indexSet)
                         vibrate(style: .rigid)
        }
        .onMove { indexSet, newIndex in
            vibrate(style: .soft)
            viewModel.habits.move(fromOffsets: indexSet, toOffset: newIndex)
            for (i, habit) in viewModel.habits.enumerated() {
                habit.sortOrder = Int16(i)
            }
            viewModel.saveContext()
        }
//        .alert("Delete Habit?",
//               isPresented: $showDeleteAlert,
//               presenting: pendingDeleteIndex) { indexSet in
//
//            Button("Cancel", role: .cancel) {}
//
//            Button("Delete", role: .destructive) {
//                viewModel.deleteHabit(offsets: indexSet)
//                vibrate(style: .rigid)
//            }
//
//        } message: { _ in
//            Text("Are you sure you want to delete this habit? This action cannot be undone.")
//        }

        
    }
}

#Preview {
    HabitRow(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}



