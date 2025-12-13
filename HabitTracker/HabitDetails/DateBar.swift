//
//  DateBar.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//

import SwiftUI

let nameColumnWidth: CGFloat = 180
let dayColumnWidth: CGFloat = 40

var gridColumns: [GridItem] {
    [
        GridItem(.fixed(nameColumnWidth), alignment: .leading),
        GridItem(.fixed(dayColumnWidth)),
        GridItem(.fixed(dayColumnWidth)),
        GridItem(.fixed(dayColumnWidth)),
        GridItem(.fixed(dayColumnWidth)),
        GridItem(.fixed(dayColumnWidth)),
    ]
}
struct DateBar: View {
    @Binding var dates: [Date]
    @EnvironmentObject var viewModel: HabitTrackerViewModel

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let nameWidth = totalWidth * 0.45
            let dayWidth = (totalWidth * 0.55) / CGFloat(dates.count)

            HStack(spacing: 0) {

                Color.clear
                    .frame(width: nameWidth)

                HStack(spacing: 0) {
                    ForEach(dates, id: \.self) { date in
                        VStack(spacing: 2) {
                            Text(viewModel.formatDayForDisplay(date))
                                .font(.caption2)
                                .foregroundColor(.secondary)

                            Text(viewModel.formatDateForDisplay(date))
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .frame(width: dayWidth)
                    }
                }
            }
        }
        .frame(height: 32)
    }
}





#Preview {
    DateBar(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}

