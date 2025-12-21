

import Foundation
import CoreData
import SwiftUI


extension Habit {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Habit> {
        return NSFetchRequest<Habit>(entityName: "Habit")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var datesCompleted: NSObject?
    @NSManaged public var id: UUID?
    @NSManaged public var priorityColor: NSObject?
    @NSManaged public var note: String?
    @NSManaged public var frequency: String?
    @NSManaged public var startDate: Date?
    @NSManaged public var noOfDays: NSNumber?
    @NSManaged public var progress: NSNumber?
    @NSManaged public var user: User?
    @NSManaged public var isNotify: NSNumber?
    @NSManaged public var sortOrder : Int16
    @NSManaged public var icon: String?

}
