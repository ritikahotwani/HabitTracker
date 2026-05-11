import WidgetKit
import Foundation

// MARK: - Widget State

enum HabitListWidgetState {
    case loggedOut
    case noHabits
    case hasHabits
}

// MARK: - Per-Habit Row Data

struct HabitRowData: Identifiable {
    let id: UUID
    let name: String
    let icon: String
    /// Serialized UIColor — decoded at draw time to avoid storing UIColor in a value type
    let habitColorData: Data?
    let completedDates: [Date]

    func isCompleted(on date: Date) -> Bool {
        completedDates.contains { Calendar.current.isDate($0, inSameDayAs: date) }
    }
}

// MARK: - Timeline Entry

struct HabitListEntry: TimelineEntry {
    let date: Date
    let state: HabitListWidgetState
    /// Habits to display (already capped if needed; provider decides limit)
    let habits: [HabitRowData]
    /// 7 consecutive dates representing the current week, ordered by calendar's firstWeekday
    let weekDays: [Date]
    /// Single-character labels derived from weekDays (e.g. ["S","M","T","W","T","F","S"])
    let weekdayLabels: [String]
}
