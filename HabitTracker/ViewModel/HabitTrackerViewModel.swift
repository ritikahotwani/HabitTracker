//
//  TitleMonth.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 24/08/25.
//

import Foundation
import SwiftUI
import CoreData

class HabitTrackerViewModel:ObservableObject{
    
    @Published var habits : [Habit] = []
    @Published var currentUser: User?
    @Published var authError: String?
    
    private let context: NSManagedObjectContext
    private let userDefaultsKey = "loggedInUserId"


    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        restoreLoggedInUser()
    }
    private func restoreLoggedInUser() {
        guard let idString = UserDefaults.standard.string(forKey: userDefaultsKey),
              let id = UUID(uuidString: idString) else { return }
        
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let user = try context.fetch(request).first {
                currentUser = user
                fetchHabits()
            }
        } catch {
            authError = "Failed to restore user: \(error.localizedDescription)"
            print("Error restoring user: \(error.localizedDescription)")
        }
    }
    
    func setLoggedInUser(_ user: User) {
        currentUser = user
        UserDefaults.standard.set(user.userId?.uuidString, forKey: userDefaultsKey)
    }

    func clearLoggedInUser() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func signUpUser(email: String, password: String, name: String) -> Bool {
        // Check if user already exists
        let checkRequest = User.fetchRequest()
        checkRequest.predicate = NSPredicate(format: "userEmail == %@", email)
        checkRequest.fetchLimit = 1
        
        do {
            if try context.fetch(checkRequest).first != nil {
                authError = "User with this email already exists"
                return false
            }
        } catch {
            authError = "Error checking existing user: \(error.localizedDescription)"
            return false
        }
        
        let user = User(context: context)
        user.userId = UUID()
        user.userEmail = email
        user.userPassword = password
        user.userName = name
        
        if saveContext() {
            setLoggedInUser(user)
            return true
        }
        return false
    }
    
//    func signUpUser(email:String, password:String,name:String) -> Bool{
//        let user = User(context: context)
//        user.userId = UUID()
//        user.userEmail = email
//        user.userPassword = password
//        user.userName = name
//        save()
//        setLoggedInUser(user)
//        currentUser = user
//        return true
//    }
//    
    func signInUser(email: String, password: String) -> Bool {
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "userEmail == %@ AND userPassword == %@", email, password)
        request.fetchLimit = 1
        
        do {
            if let user = try context.fetch(request).first {
                setLoggedInUser(user)
                fetchHabits()
                return true
            } else {
                authError = "Invalid email or password"
            }
        } catch {
            authError = "Sign in error: \(error.localizedDescription)"
            print("Error signing in: \(error.localizedDescription)")
        }
        return false
    }
    
    func signOut() -> Bool{
        currentUser = nil
        clearLoggedInUser()
        habits = []
        return true
    }
    
    func addHabit(name: String,priorityColor: NSObject,frequency:String,note:String,noOfDays:Int, completion: (() -> Void)? = nil){
        guard let user = currentUser else {
            authError = "No user logged in"
               print("No user logged in")
               return
           }
           
        let habit = Habit(context: context)
        habit.user = user
        habit.name = name
        habit.id = UUID()
        habit.datesCompleted = [] as NSObject?
        habit.priorityColor = priorityColor
        habit.frequency = frequency
        habit.startDate = Date()
        habit.note = note
        habit.noOfDays = NSNumber(value: noOfDays)
        
        if saveContext() {
            completion?()
        }
    }
    
    func fetchHabits(){
        guard let user = currentUser else {
            habits = []
            return
        }
        
        let request = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        
        do {
            habits = try context.fetch(request)
        } catch {
            authError = "Failed to fetch habits: \(error.localizedDescription)"
            print("Error fetching habits: \(error.localizedDescription)")
            habits = []
        }
    }
    
    func deleteHabit(offsets: IndexSet){
        offsets.forEach { index in
            context.delete(habits[index])
        }
        saveContext()
    }
    
    func toggleHabit(habit: Habit, date: Date) {
        guard habit.id != nil else { return }
        
        var currentDates = habit.completedDatesArray
        let calendar = Calendar.current
        
        if let existingIndex = currentDates.firstIndex(where: {
            calendar.isDate($0, inSameDayAs: date)
        }) {
            currentDates.remove(at: existingIndex)
        } else {
            currentDates.append(date)
        }
        
        habit.completedDatesArray = currentDates
        saveContext()
    }
    
    @discardableResult
    private func saveContext() -> Bool {
        guard context.hasChanges else { return true }
        
        do {
            try context.save()
            fetchHabits()
            return true
        } catch {
            authError = "Failed to save: \(error.localizedDescription)"
            print("Error saving context: \(error.localizedDescription)")
            return false
        }
    }
}


