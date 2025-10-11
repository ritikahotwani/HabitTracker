//
//  PersistenceController.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 15/08/25.
//



import Foundation
import SwiftUI

let calendar = Calendar.current
let today = Date()
extension Habit {
    var habitColor: Color {
        guard let data = priorityColor as? Data else { return .red }
        return Color.fromData(data) ?? .red
    }
}

extension Habit {
    var completedDatesArray: [Date] {
        get {
            return (datesCompleted as? [Date]) ?? []
        }
        set {
            datesCompleted = newValue as NSObject
        }
    }
}


extension Habit : Identifiable {
    
}
struct MonthCount: Identifiable {
    let id = UUID()
    let month: String
    let count: Int
}

extension Habit {
    
    var completedCountByMonth: [MonthCount] {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM yyyy"
        
        let grouped = Dictionary(grouping: completedDatesArray) { date in
            dateFormatter.string(from: date)
        }
        
        return grouped.map { (key, value) in
            MonthCount(month: key, count: value.count)
        }
        .sorted { first, second in
            guard let firstDate = dateFormatter.date(from: first.month),
                  let secondDate = dateFormatter.date(from: second.month) else {
                return false
            }
            return firstDate < secondDate
        }
    }
    
   
}
extension Habit {
    

    var weeklyProgress: (start: Date, end: Date, progress: CGFloat)? {
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else { return nil }
        let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
        
        let completedThisWeek = completedDatesArray.filter {
            $0 >= weekStart && $0 < weekEnd
        }
        
        let totalDays = Double(truncating: noOfDays ?? 7)
        let progress = CGFloat(Double(completedThisWeek.count) / totalDays)
        
        return (start: weekStart, end: weekEnd-1, progress: progress)
    }
    var monthlyProgress: (start: Date, end: Date, progress: CGFloat)? {
        guard let monthStart = calendar.dateInterval(of: .month, for: today)?.start else { return nil }
        let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
        
        let completedThisMonth = completedDatesArray.filter {
            $0 >= monthStart && $0 < monthEnd
        }
        
        // Calculate number of weeks in this month
        let weeksInMonth = calendar.dateComponents([.weekOfMonth], from: monthStart, to: monthEnd).weekOfMonth ?? 4
        
        // Total target days for this month
        let daysPerWeek = Double(truncating: noOfDays ?? 7)
        let totalTargetDays = daysPerWeek * Double(weeksInMonth)
        
        let progress = totalTargetDays > 0
        ? CGFloat(Double(completedThisMonth.count) / totalTargetDays)
        : 0.0
        
        return (start: monthStart, end: monthEnd, progress: progress)
    }
}
