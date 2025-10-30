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
    
    var body: some View {
        ForEach(viewModel.habits) { habit in
            HStack(spacing: 8){
                HabitName(habit: habit)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .frame(maxWidth: 120, alignment: .leading)
                Spacer(minLength: 4)
                HabitCheckBox(habit: habit, dates: $dates)
            }
            .padding()
            .listRowInsets(EdgeInsets())
        }
        
        .onDelete { indexSet in
            viewModel.deleteHabit(offsets:indexSet)
            vibrate(style: .rigid)
        }
        .onMove { indexSet, newIndex in
            vibrate(style: .soft)
            viewModel.habits.move(fromOffsets: indexSet, toOffset: newIndex)
        }
        
    }
}

#Preview {
    HabitRow(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}



