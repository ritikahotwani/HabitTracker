//
//  PersistenceController.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//



import CoreData
struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "HabitTracker")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        // Performance optimizations
        guard let description = container.persistentStoreDescriptions.first else {
            fatalError("Failed to retrieve a persistent store description.")
        }
        
        description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
        description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
        
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                #if DEBUG
                fatalError("Unresolved error \(error), \(error.userInfo)")
                #else
                print("Core Data error: \(error), \(error.userInfo)")
                #endif
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // Test case
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Create sample data for previews
        let user = User(context: context)
        user.userId = UUID()
        user.userName = "Preview User"
        user.userEmail = "preview@example.com"
        user.userPassword = "password"
        
        let habit = Habit(context: context)
        habit.id = UUID()
        habit.name = "Sample Habit"
        habit.user = user
        habit.startDate = Date()
        habit.frequency = "Daily"
        habit.noOfDays = 30
        
        do {
            try context.save()
        } catch {
            print("Preview context save failed: \(error)")
        }
        
        return controller
    }()
    
    func deleteAllData() {
        let entities = container.managedObjectModel.entities
        entities.compactMap({ $0.name }).forEach(clearEntity)
    }
    
    private func clearEntity(_ entity: String) {
        let context = container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try container.persistentStoreCoordinator.execute(deleteRequest, with: context)
        } catch {
            print("Failed to clear entity \(entity): \(error)")
        }
    }
}
