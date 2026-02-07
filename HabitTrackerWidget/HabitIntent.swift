import Foundation
import AppIntents
import CoreData
import SwiftUI

// MARK: - Habit Entity for App Intents
struct HabitEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
    static var defaultQuery = HabitQuery()
    
    var id: UUID
    var name: String
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
    
    init(habit: Habit) {
        self.id = habit.id ?? UUID()
        self.name = habit.name ?? "Unknown Habit"
    }
}

// MARK: - Habit Query
struct HabitQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitEntity] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "id IN %@", identifiers)
        
        do {
            let habits = try context.fetch(request)
            return habits.map { HabitEntity(habit: $0) }
        } catch {
            print("Failed to fetch habits: \(error)")
            return []
        }
    }
    
    func suggestedEntities() async throws -> [HabitEntity] {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        // Filter out archived habits if necessary
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Habit.sortOrder, ascending: true)]
        
        do {
            let habits = try context.fetch(request)
            return habits.map { HabitEntity(habit: $0) }
        } catch {
            print("Failed to fetch suggested habits: \(error)")
            return []
        }
    }
}

// MARK: - Configuration Intent
struct SelectHabitIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Select Habit"
    static var description: IntentDescription = "Choose a habit to track."
    
    @Parameter(title: "Habit")
    var habit: HabitEntity?
}

// MARK: - Interaction Intent (Toggle)
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
        guard let uuid = UUID(uuidString: habitID) else {
            return .result()
        }
        
        let context = PersistenceController.shared.container.newBackgroundContext()
        // Use background context for updates to avoid blocking main thread
        
        await context.perform {
            let request: NSFetchRequest<Habit> = Habit.fetchRequest()
            request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
            request.fetchLimit = 1
            
            do {
                if let habit = try context.fetch(request).first {
                    let today = Calendar.current.startOfDay(for: Date())
                    var completedDates = (habit.datesCompleted as? [Date]) ?? []
                    
                    // Check if completed today
                    if completedDates.contains(where: { Calendar.current.isDate($0, inSameDayAs: today) }) {
                        // Untick: Remove today
                        completedDates.removeAll { Calendar.current.isDate($0, inSameDayAs: today) }
                    } else {
                        // Tick: Add today
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
