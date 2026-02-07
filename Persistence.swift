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
        } else {
             // Configure App Group for shared storage between App and Widget
             let appGroupID = "group.com.ritikahotwani.HabitTracker"
             if let storeURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?.appendingPathComponent("HabitTracker.sqlite") {
                 let description = NSPersistentStoreDescription(url: storeURL)
                 
                 // Required for Core Data history tracking (useful for widget updates)
                 description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                 description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                 
                 container.persistentStoreDescriptions = [description]
             } else {
                 print("WARNING: App Group container not found. Falling back to default store. Ensure App Groups capability is enabled with ID: \(appGroupID)")
                 // Fallback to default, but ensure options are set
                 if let description = container.persistentStoreDescriptions.first {
                     description.setOption(true as NSNumber, forKey: NSPersistentHistoryTrackingKey)
                     description.setOption(true as NSNumber, forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
                 }
             }
        }
        
        // Load stores
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
        user.userId = "id"
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
