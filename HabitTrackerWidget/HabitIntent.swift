import Foundation
import AppIntents
import CoreData

// MARK: - Toggle Habit Completion (used by the check-circle button in the widget)
struct ToggleHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Habit"
    static var openAppWhenRun: Bool = false

    @Parameter(title: "Habit ID")
    var habitID: String

    init() {}

    init(habitID: UUID) {
        self.habitID = habitID.uuidString
    }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: habitID) else { return .result() }

        let context = PersistenceController.shared.container.newBackgroundContext()

        await context.perform {
            let request: NSFetchRequest<Habit> = Habit.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1

            do {
                if let habit = try context.fetch(request).first {
                    let today = Calendar.current.startOfDay(for: Date())
                    var completedDates = (habit.datesCompleted as? [Date]) ?? []

                    if completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                        completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
                    } else {
                        completedDates.append(today)
                    }

                    habit.datesCompleted = completedDates as NSObject
                    try context.save()
                }
            } catch {
                print("Failed to toggle habit: \(error)")
            }
        }

        return .result()
    }
}
