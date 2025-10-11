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
            DateBar(dates: $dates)
                
            Section{
                HabitRow(dates: $dates)
            }
            
        }
        
         .scrollContentBackground(.hidden)
        .background(Color.clear)
        .listSectionSpacing(0)
    }
}

#Preview {
    HabitList(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}
