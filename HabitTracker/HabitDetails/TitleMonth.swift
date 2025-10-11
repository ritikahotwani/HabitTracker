//
//  TitleMonth.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI

struct TitleMonth: View {
    let habit: Habit
    let title: String
    
    @Binding var daysInSelectedMonth: [Date]
    @State private var monthSelected: Months
    @State private var currentYear: Int
    
    private let calendar = Calendar.current
    
    init(habit: Habit, title: String, daysInSelectedMonth: Binding<[Date]>) {
        self.habit = habit
        self.title = title
        self._daysInSelectedMonth = daysInSelectedMonth
        
        let currentMonthIndex = Calendar.current.component(.month, from: Date()) - 1
        self._monthSelected = State(initialValue: Months.allCases[currentMonthIndex])
        self._currentYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            MonthPicker(monthSelected: $monthSelected)
        }
        .onChange(of: monthSelected) { _ in updateDays() }
        .onChange(of: currentYear) { _ in updateDays() }
        .task { updateDays() }
    }
    
    private func updateDays() {
        guard let monthStart = calendar.date(from: DateComponents(year: currentYear, month: monthSelected.number)),
              let range = calendar.range(of: .day, in: .month, for: monthStart) else {
            daysInSelectedMonth = []
            return
        }
        
        daysInSelectedMonth = range.compactMap { day in
            calendar.date(from: DateComponents(year: currentYear, month: monthSelected.number, day: day))
        }
    }
}


#Preview {
        let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
        testHabit.name = "Ritika"
        let calendar = Calendar.current
        testHabit.completedDatesArray = [
            calendar.date(byAdding: .day, value: -1, to: Date())!,
            calendar.date(byAdding: .day, value: -3, to: Date())!
        ]
    return TitleMonth(habit: testHabit, title: "ed",daysInSelectedMonth:.constant([]) )
}

