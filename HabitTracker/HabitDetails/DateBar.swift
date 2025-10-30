//
//  DateBar.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//

import SwiftUI

struct DateBar: View {
    @Binding var dates: [Date]
    @EnvironmentObject var viewModel: HabitTrackerViewModel
    
    var body: some View {
        HStack {
            Spacer()
            
            ForEach(dates, id: \.self) { date in
                VStack(spacing: 2) {
                    Text(viewModel.formatDayForDisplay(date))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(viewModel.formatDateForDisplay(date))
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
                .frame(maxWidth: 40)
            }
        }
        .padding()
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color(.systemGray6))
    }
}

#Preview {
    DateBar(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}

