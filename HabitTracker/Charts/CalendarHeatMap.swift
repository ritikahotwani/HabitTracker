//
//  CalendarHeatMap.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 17/08/25.
//
import SwiftUI

struct CalendarHeatMap: View {
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 7)
    
    var habit: Habit
    @State private var daysInSelectedMonth: [Date]
    
    init(habit: Habit) {
        self.habit = habit
        self.daysInSelectedMonth = []
    }
    
    
    var body: some View {
        VStack(alignment: .leading) {
            TitleMonth(habit: habit, title: "Habit calendar",daysInSelectedMonth: $daysInSelectedMonth)
            
            LazyVGrid(columns: columns, spacing: 5) {
                
                ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                    Text(day.prefix(3))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
                
                if let firstDate = daysInSelectedMonth.first {
                    let weekdayOffset = (calendar.component(.weekday, from: firstDate) - calendar.firstWeekday + 7) % 7
                    ForEach(0..<weekdayOffset, id: \.self) { _ in
                        Color.clear.frame(height: 30)
                    }
                }
                ForEach(daysInSelectedMonth, id: \.self) { date in
                    let isCompleted = habit.completedDatesArray.contains {
                        calendar.isDate($0, inSameDayAs: date)
                    }
                    let isFuture = calendar.startOfDay(for: date) > calendar.startOfDay(for: Date())
                    
                    Text("\(calendar.component(.day, from: date))")
                        .font(.system(size: 12, weight: .medium, design: .monospaced))
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .background(
                            isFuture ? Color.gray.opacity(0.1) :
                                (isCompleted ? habit.habitColor.opacity(1) : habit.habitColor.opacity(0.3))
                        )
                        .cornerRadius(4)
                }
            }
        }
        .padding()
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
    return CalendarHeatMap(habit: testHabit)
}
