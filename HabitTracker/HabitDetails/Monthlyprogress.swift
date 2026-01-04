//
//  MonthlyProgress.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI


struct MonthlyProgress: View {
    let habit: Habit
    
    @State private var monthSelected: Months
    @State private var currentYear: Int
    
    private let calendar = Calendar.current
    
    init(habit: Habit) {
        self.habit = habit
        
        let currentMonthIndex = Calendar.current.component(.month, from: Date()) - 1
        self._monthSelected = State(initialValue: Months.allCases[currentMonthIndex])
        self._currentYear = State(initialValue: Calendar.current.component(.year, from: Date()))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Monthly Progress")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 16) {
                    MonthPicker(monthSelected: $monthSelected)
                    
                    HStack(spacing: 8) {
                        Button {
                            withAnimation { currentYear -= 1 }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                        
                        Text("\(String(currentYear))")
                            .font(.subheadline)
                            .monospacedDigit()
                        
                        Button {
                            withAnimation { currentYear += 1 }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .fontWeight(.bold)
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
            }
            
            if let progressData = progressForSelectedMonth {
                MonthlyProgressBar(
                    habit: habit,
                    progress: progressData.progress,
                    startDate: progressData.start,
                    endDate: progressData.end
                )
            }
        }
        .padding()
    }
    
    // MARK: - Computed Properties
    
    private var progressForSelectedMonth: (start: Date, end: Date, progress: CGFloat)? {
        guard let monthStart = startOfSelectedMonth,
              let monthEnd = endOfSelectedMonth else {
            return nil
        }
        
        let completedThisMonth = habit.completedDatesArray.filter {
            $0 >= monthStart && $0 < monthEnd
        }
        
        let weeklyTarget = habit.noOfDays?.doubleValue ?? 7
        let weeksInMonth = calendar.range(of: .weekOfMonth, in: .month, for: monthStart)?.count ?? 4
        let totalTargetDays = weeklyTarget * Double(weeksInMonth)
        
        let progress = totalTargetDays > 0 ? CGFloat(Double(completedThisMonth.count) / totalTargetDays) : 0
        
        return (start: monthStart, end: monthEnd, progress: min(progress, 1.0))
    }
    
    private var startOfSelectedMonth: Date? {
        calendar.date(from: DateComponents(year: currentYear, month: monthSelected.number))
    }
    
    private var endOfSelectedMonth: Date? {
        startOfSelectedMonth.flatMap {
            calendar.date(byAdding: .month, value: 1, to: $0)
        }
    }
}
