//
//  DateHelpers.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 24/08/25.
//

import Foundation

extension HabitTrackerViewModel{
    func loadRecentDates() -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        let today = Date()
        
        dates = (0..<5).map { offset in
            calendar.date(byAdding: .day, value: -offset, to: today)!
            
        }
        return dates

    }
    func formatDateForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    func formatDayForDisplay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return formatter.string(from: date)
    }

    func convertDate(date dayString: String) -> Date? {
        
        let calendar = Calendar.current
        
        let currentComponents = calendar.dateComponents([.year, .month], from: Date())
        
        // Create full date string like "31-07-2025"
        guard let day = Int(dayString),
              let month = currentComponents.month,
              let year = currentComponents.year else {
            return nil
        }
        
        let fullDateString = "\(day)-\(month)-\(year)"
        
        let formatter = DateFormatter()
        formatter.dateFormat = "d-M-yyyy"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        
        return formatter.date(from: fullDateString)
    }
    
}
