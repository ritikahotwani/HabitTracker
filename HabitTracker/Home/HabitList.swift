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
        
        
        List {
            Section{
            DateBar(dates: $dates)
                HabitRow(dates: $dates)
            } .padding(2)
            
        }
       
        .scrollContentBackground(.hidden)
        
        .listSectionSpacing(0)
    }
}

#Preview {
    HabitList(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}
