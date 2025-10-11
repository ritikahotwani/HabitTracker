//
//  ProgressLineChart.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 18/08/25.
//

import SwiftUI
import Charts

struct ProgressLineChart: View {
    var habit: Habit
    let calendar = Calendar.current
    
    var body: some View {
        
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let startOfWeek = calendar.date(byAdding: .day, value: -((weekday - calendar.firstWeekday + 7) % 7), to: today)!

        // Formatter for "Mon", "Tue", etc.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "EEE"

        // Build cumulative progress data for the current week
        var cumulativeCount = 0
        let weekProgress = (0..<7).compactMap { offset -> (day: String, progress: Int)? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfWeek) else { return nil }
//            if date > today { return nil }
            if habit.completedDatesArray.contains(where: { calendar.isDate($0, inSameDayAs: date) }) {
                cumulativeCount += 1
            }
            let dayLabel = formatter.string(from: date)
            return (day: dayLabel, progress: cumulativeCount)
        }

        return Chart {
            
            ForEach(Array(weekProgress.enumerated()), id: \.offset) { index, entry in
                LineMark(
                    x: .value("Day", entry.day),
                    y: .value("Progress", entry.progress)
                )
                .foregroundStyle(habit.habitColor)
                .interpolationMethod(.monotone)

                PointMark(
                    x: .value("Day", entry.day),
                    y: .value("Progress", entry.progress)
                )
                .foregroundStyle(habit.habitColor)
            }
        }
        .frame(height: 200)
        .padding()
    }
}
