//
//  BarChart.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 17/08/25.
//
import SwiftUI
import Charts

struct BarChart: View {
    @ObservedObject var habit: Habit
    var body: some View {
        
        VStack{
            Text("Monthly Progress")
                .font(.headline)
                .foregroundColor(.gray)
                .padding(.bottom, 3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Chart {
                ForEach(habit.completedCountByMonth) { item in
                    BarMark(
                        x: .value("Month", String(item.month.prefix(3))),
                        y: .value("Completions", item.count)
                    )
                    .annotation(position: .top) {
                        Text("\(item.count)")
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                    
                    .foregroundStyle(habit.habitColor)
                }
            }
            .padding(.trailing,20)
            .chartYAxis(.hidden)
            .frame(width: 100,height: 200)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

#Preview {
    let testHabit = Habit(context: PersistenceController.shared.container.viewContext)
    testHabit.name = "Ritika"
    let calendar = Calendar.current
    let today = Date()
    testHabit.completedDatesArray  = [
        calendar.date(byAdding: .day, value: -7, to: today)!, // 7 days ago
        calendar.date(byAdding: .day, value: -6, to: today)!,
        calendar.date(byAdding: .day, value: -5, to: today)!,
        calendar.date(byAdding: .day, value: -3, to: today)!,
        calendar.date(byAdding: .day, value: -1, to: today)!,
        today,
        
        calendar.date(byAdding: .day, value: -14, to: today)!, // 2 weeks ago
        calendar.date(byAdding: .day, value: -13, to: today)!,
        calendar.date(byAdding: .day, value: -11, to: today)!,
        
        calendar.date(byAdding: .day, value: -20, to: today)!, // 3 weeks ago
        calendar.date(byAdding: .day, value: -19, to: today)!,
        
        calendar.date(byAdding: .day, value: -28, to: today)!,
    // 4 weeks ago
        calendar.date(byAdding: .day, value: -56, to: today)!
    ]
   return BarChart(habit: testHabit)
}








