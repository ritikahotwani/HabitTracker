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
    @Environment(\.scenePhase) private var scenePhase

    
    var body: some View {
        VStack {
            DateBar(dates: $dates)

            if viewModel.habits.count == 0 {
                NoHabitsView()
                    .offset(y: -70)
            } else {
                List {
                    Section {
                        HabitRow(dates: $dates)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .listSectionSpacing(0)
            }
        }
        .task(id: scenePhase) {
            guard scenePhase == .active else { return }

            let today = Calendar.current.startOfDay(for: Date())
            let firstDate = Calendar.current.startOfDay(for: dates.first ?? Date())

            if today != firstDate {
                dates = viewModel.loadRecentDates()
            }
        }

    }

        
    
}

#Preview {
    HabitList(dates: .constant(HabitTrackerViewModel().loadRecentDates()))
}
