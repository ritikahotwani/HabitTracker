import WidgetKit
import SwiftUI
import CoreData

let widgetAppGroupSuite = "group.com.ritikahotwani.HabitTracker"
let widgetSelectedHabitKey = "widget_selected_habit_id"

struct HabitEntry: TimelineEntry {
    let date: Date
    let habitName: String
    let habitIcon: String
    let isCompleted: Bool
    let streakCount: Int
    let habitID: UUID?
    let isValid: Bool
    let completedDates: [Date]
    let habitColorData: Data?
}

struct HabitWidgetProvider: TimelineProvider {

    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: Date(), habitName: "Morning Run", habitIcon: "🏃", isCompleted: false, streakCount: 5, habitID: UUID(), isValid: true, completedDates: [], habitColorData: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) {
        completion(fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let entry = fetchEntry()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        completion(Timeline(entries: [entry], policy: .after(tomorrow)))
    }

    private func fetchEntry() -> HabitEntry {
        let defaults = UserDefaults(suiteName: widgetAppGroupSuite)
        guard let idString = defaults?.string(forKey: widgetSelectedHabitKey),
              let uuid = UUID(uuidString: idString) else {
            return HabitEntry(date: Date(), habitName: "", habitIcon: "", isCompleted: false, streakCount: 0, habitID: nil, isValid: false, completedDates: [], habitColorData: nil)
        }

        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        request.fetchLimit = 1

        do {
            if let habit = try context.fetch(request).first {
                let today = Calendar.current.startOfDay(for: Date())
                let completedDates = (habit.datesCompleted as? [Date]) ?? []
                let isCompleted = completedDates.contains { Calendar.current.isDate($0, inSameDayAs: today) }
                let streak = calculateStreak(dates: completedDates)

                return HabitEntry(
                    date: Date(),
                    habitName: habit.name ?? "Unknown",
                    habitIcon: habit.icon ?? "",
                    isCompleted: isCompleted,
                    streakCount: streak,
                    habitID: habit.id,
                    isValid: true,
                    completedDates: completedDates,
                    habitColorData: habit.priorityColor as? Data
                )
            }
        } catch {
            print("Widget fetch error: \(error)")
        }

        return HabitEntry(date: Date(), habitName: "", habitIcon: "", isCompleted: false, streakCount: 0, habitID: nil, isValid: false, completedDates: [], habitColorData: nil)
    }

    private func calculateStreak(dates: [Date]) -> Int {
        let sortedDates = dates.map { Calendar.current.startOfDay(for: $0) }.sorted(by: >)
        guard !sortedDates.isEmpty else { return 0 }
        var streak = 0
        let today = Calendar.current.startOfDay(for: Date())
        var checkDate = today
        if !sortedDates.contains(today) {
            checkDate = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        }
        for date in sortedDates {
            if date == checkDate {
                streak += 1
                checkDate = Calendar.current.date(byAdding: .day, value: -1, to: checkDate)!
            } else if date > checkDate {
                continue
            } else {
                break
            }
        }
        return streak
    }
}
