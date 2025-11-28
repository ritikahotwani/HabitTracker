//
//  HabitList.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 14/08/25.
//

import SwiftUI

struct HabitList: View {
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    @Binding  var dates: [Date]
    
    var body: some View {
        
        DateBar(dates: $dates)
        
        
        if viewModel.habits.count == 0{
            NoHabitsView()
                .offset(y: -70)

        }else{
            List {
                Section{
                    
                    HabitRow(dates: $dates)
                }
            }
            
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .listSectionSpacing(0)
        }}
    
}

#Preview {
    HabitList(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}
