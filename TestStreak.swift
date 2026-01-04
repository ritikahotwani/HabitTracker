import Foundation

func calculateStreaks(from datesCompleted: [Date]) -> (currentStreak: Int, bestStreak: Int) {
    let calendar = Calendar.current

    // Normalize dates to remove time component
    let normalizedDates = Set(datesCompleted.map {
        calendar.startOfDay(for: $0)
    })

    // Sort dates in descending order (most recent first)
    let sortedDates = normalizedDates.sorted(by: >)

    var currentStreak = 0
    var bestStreak = 0
    var streak = 0

    var previousDate: Date?

    for date in sortedDates {
        if let prev = previousDate {
            if let diff = calendar.dateComponents([.day], from: date, to: prev).day {
                if diff == 1 {
                    // Consecutive day
                    streak += 1
                } else if diff > 1 {
                    // Break in streak
                    streak = 1
                }
            }
        } else {
            streak = 1
        }

        bestStreak = max(bestStreak, streak)
        previousDate = date
    }

    // Calculate current streak
    var todayStreak = 0
    // Mock "Today" as Jan 1, 2025
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    let mockToday = dateFormatter.date(from: "2025-01-01")!
    
    let today = calendar.startOfDay(for: mockToday)
    
    // Check if streak is active (Today OR Yesterday must be present)
    var checkDate = today
    if !normalizedDates.contains(today) {
        // If not done today, check yesterday
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           normalizedDates.contains(yesterday) {
            checkDate = yesterday
        } else {
            return (currentStreak: 0, bestStreak: bestStreak)
        }
    }
    
    // Count backward from the active date (Today or Yesterday)
    while normalizedDates.contains(checkDate) {
        todayStreak += 1
        guard let prevDate = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
        checkDate = prevDate
    }

    return (currentStreak: todayStreak, bestStreak: bestStreak)
}

// Test Case
// Dec 31 2024 is DONE. Jan 1 2025 (Today) is NOT done.
// Expected Current Streak: 1 (from Dec 31)
let dateFormatter = DateFormatter()
dateFormatter.dateFormat = "yyyy-MM-dd"
let dec31 = dateFormatter.date(from: "2024-12-31")!
// Jan 1 is NOT in the list

let dates = [dec31]
let result = calculateStreaks(from: dates)

print("Dates: \(dates)")
print("Result: Current=\(result.currentStreak), Best=\(result.bestStreak)")

if result.currentStreak == 1 {
    print("SUCCESS: Streak persisted from yesterday!")
} else {
    print("FAILURE: Streak reset to \(result.currentStreak)")
}
