import WidgetKit
import CoreData

// Shared with the main app via the same string literal in HabitTrackerViewModel
private let habitListWidgetUserIdKey = "widget_logged_in_user_id"

struct HabitListWidgetProvider: TimelineProvider {

    // MARK: - TimelineProvider

    func placeholder(in context: Context) -> HabitListEntry {
        makePreviewEntry()
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitListEntry) -> Void) {
        completion(context.isPreview ? makePreviewEntry() : fetchEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitListEntry>) -> Void) {
        let entry = fetchEntry()
        // Refresh at next midnight so day circles update correctly
        let nextMidnight = Calendar.current.date(
            byAdding: .day, value: 1,
            to: Calendar.current.startOfDay(for: Date())
        ) ?? Date()
        completion(Timeline(entries: [entry], policy: .after(nextMidnight)))
    }

    // MARK: - Data Fetching

    private func fetchEntry() -> HabitListEntry {
        let weekDays = currentWeekDays()
        let labels = weekdayInitials(for: weekDays)

        // Auth check: the main app writes the logged-in user ID here on login/logout
        let defaults = UserDefaults(suiteName: widgetAppGroupSuite)
        guard let userId = defaults?.string(forKey: habitListWidgetUserIdKey) else {
            return HabitListEntry(
                date: Date(), state: .loggedOut,
                habits: [], weekDays: weekDays, weekdayLabels: labels
            )
        }

        let context = PersistenceController.shared.container.viewContext

        // Resolve user entity
        let userRequest: NSFetchRequest<User> = User.fetchRequest()
        userRequest.predicate = NSPredicate(format: "userId == %@", userId)
        userRequest.fetchLimit = 1

        guard let user = (try? context.fetch(userRequest))?.first else {
            return HabitListEntry(
                date: Date(), state: .loggedOut,
                habits: [], weekDays: weekDays, weekdayLabels: labels
            )
        }

        // Fetch all habits for this user, sorted consistently with the main app
        let habitRequest: NSFetchRequest<Habit> = Habit.fetchRequest()
        habitRequest.predicate = NSPredicate(format: "user == %@", user)
        habitRequest.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "startDate", ascending: false)
        ]

        let habits = (try? context.fetch(habitRequest)) ?? []

        guard !habits.isEmpty else {
            return HabitListEntry(
                date: Date(), state: .noHabits,
                habits: [], weekDays: weekDays, weekdayLabels: labels
            )
        }

        let rowData = habits.map { habit in
            HabitRowData(
                id: habit.id ?? UUID(),
                name: habit.name ?? "Habit",
                icon: habit.icon ?? "",
                habitColorData: habit.priorityColor as? Data,
                completedDates: habit.completedDatesArray
            )
        }

        return HabitListEntry(
            date: Date(), state: .hasHabits,
            habits: rowData, weekDays: weekDays, weekdayLabels: labels
        )
    }

    // MARK: - Date Helpers (mirrors Habit+Extension.swift logic)

    /// Returns 7 dates starting from the current week's first day, respecting Calendar.firstWeekday
    private func currentWeekDays() -> [Date] {
        let calendar = Calendar.current
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: Date())?.start else { return [] }
        return (0..<7).compactMap { calendar.date(byAdding: .day, value: $0, to: weekStart) }
    }

    /// Derives single-character weekday labels directly from the dates so labels always align with circles
    private func weekdayInitials(for weekDays: [Date]) -> [String] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE" // "S", "M", "T", "W", "T", "F", "S"
        return weekDays.map { formatter.string(from: $0) }
    }

    // MARK: - Preview / Placeholder Entry

    private func makePreviewEntry() -> HabitListEntry {
        let weekDays = currentWeekDays()
        let labels = weekdayInitials(for: weekDays)
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) ?? today

        let sampleHabits: [HabitRowData] = [
            HabitRowData(id: UUID(), name: "Morning Run", icon: "🏃", habitColorData: nil,
                         completedDates: [yesterday, today]),
            HabitRowData(id: UUID(), name: "Read 20 mins", icon: "📚", habitColorData: nil,
                         completedDates: [yesterday]),
            HabitRowData(id: UUID(), name: "Meditate", icon: "🧘", habitColorData: nil,
                         completedDates: Array(weekDays.prefix(5))),
            HabitRowData(id: UUID(), name: "Drink Water", icon: "💧", habitColorData: nil,
                         completedDates: [today])
        ]

        return HabitListEntry(
            date: Date(), state: .hasHabits,
            habits: sampleHabits, weekDays: weekDays, weekdayLabels: labels
        )
    }
}
