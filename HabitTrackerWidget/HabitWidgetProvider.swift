import WidgetKit
import SwiftUI
import CoreData

struct HabitEntry: TimelineEntry {
    let date: Date
    let habitName: String
    let isCompleted: Bool
    let streakCount: Int
    let habitID: UUID?
    let isValid: Bool // True if habit exists and is valid
}

struct HabitWidgetProvider: AppIntentTimelineProvider {
    
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habitName: "Morning Run", isCompleted: false, streakCount: 5, habitID: UUID(), isValid: true)
    }

    func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> HabitEntry {
        await fetchHabitEntry(for: configuration)
    }

    func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<HabitEntry> {
        let entry = await fetchHabitEntry(for: configuration)
        
        // Refresh at midnight
        let calendar = Calendar.current
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date()))!
        
        return Timeline(entries: [entry], policy: .after(tomorrow))
    }
    
    private func fetchHabitEntry(for configuration: SelectHabitIntent) async -> HabitEntry {
        guard let habitID = configuration.habit?.id else {
            return HabitEntry(date: Date(), habitName: "No Habit Selected", isCompleted: false, streakCount: 0, habitID: nil, isValid: false)
        }
        
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", habitID as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let habit = try context.fetch(request).first {
                // Calculate status
                let today = Calendar.current.startOfDay(for: Date())
                let completedDates = (habit.datesCompleted as? [Date]) ?? []
                let isCompleted = completedDates.contains { Calendar.current.isDate($0, inSameDayAs: today) }
                
                // Calculate streak (simplified)
                let streak = calculateStreak(dates: completedDates)
                
                return HabitEntry(date: Date(), 
                                  habitName: habit.name ?? "Unknown", 
                                  isCompleted: isCompleted, 
                                  streakCount: streak, 
                                  habitID: habit.id, 
                                  isValid: true)
            } else {
                return HabitEntry(date: Date(), habitName: "Habit Not Found", isCompleted: false, streakCount: 0, habitID: nil, isValid: false)
            }
        } catch {
            return HabitEntry(date: Date(), habitName: "Error Loading", isCompleted: false, streakCount: 0, habitID: nil, isValid: false)
        }
    }
    
    private func calculateStreak(dates: [Date]) -> Int {
        let sortedDates = dates.map { Calendar.current.startOfDay(for: $0) }.sorted(by: >)
        guard !sortedDates.isEmpty else { return 0 }
        
        var streak = 0
        let today = Calendar.current.startOfDay(for: Date())
        var checkDate = today
        
        // If not completed today, check if completed yesterday to continue streak
        if !sortedDates.contains(today) {
            checkDate = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        }
        
        for date in sortedDates {
            if date == checkDate {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else if date > checkDate {
                continue // Should not happen if sorted, but just in case
            } else {
                break // Gap found
            }
        }
        return streak
    }
}
