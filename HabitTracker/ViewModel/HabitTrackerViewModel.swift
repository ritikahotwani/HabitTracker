//
//  TitleMonth.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 24/08/25.
//
import Foundation
import SwiftUI
import CoreData

class HabitTrackerViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    @Published var currentUser: User?
    @Published var authError: String?
    
    private let context: NSManagedObjectContext
    private let userDefaultsKey = "loggedInUserId"

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        restoreLoggedInUser()
    }
    
    // MARK: - User Management
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
            print(error.localizedDescription)
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
            print(error.localizedDescription)
        }
        return false
    }
    
    func signOut() -> Bool {
        currentUser = nil
        clearLoggedInUser()
        habits = []
        return true
    }
    
    // MARK: - Habit CRUD + Notifications
    func addHabit(name: String,
                  priorityColor: NSObject,
                  frequency: String,
                  note: String,
                  noOfDays: Int,
                  isNotify: Bool,
                  completion: (() -> Void)? = nil) {
        
        guard let user = currentUser else {
            authError = "No user logged in"
            return
        }
        
        let habit = Habit(context: context)
        habit.user = user
        habit.name = name
        habit.id = UUID()
        habit.datesCompleted = [] as NSObject
        habit.priorityColor = priorityColor
        habit.frequency = frequency
        habit.startDate = Date()
        habit.note = note
        habit.noOfDays = NSNumber(value: noOfDays)
        habit.isNotify = NSNumber(value: isNotify)
        
        if saveContext() {
            // Schedule or cancel notifications based on isNotify
            if isNotify {
                NotificationManager.shared.updateNotification(for: habit)
            } else {
                NotificationManager.shared.cancelReminder(for: habit)
            }
            completion?()
        }
    }
    
    func editHabit(habit: Habit,
                   name: String,
                   priorityColor: NSObject,
                   frequency: String,
                   note: String,
                   noOfDays: Int,
                   isNotify: Bool,
                   completion: (() -> Void)? = nil) {
        
        habit.name = name
        habit.priorityColor = priorityColor
        habit.frequency = frequency
        habit.note = note
        habit.noOfDays = NSNumber(value: noOfDays)
        habit.isNotify = NSNumber(value: isNotify)
        
        if saveContext() {
            if isNotify {
                NotificationManager.shared.updateNotification(for: habit)
            } else {
                NotificationManager.shared.cancelReminder(for: habit)
            }
            completion?()
        }
    }
    
    func deleteHabit(offsets: IndexSet) {
        offsets.forEach { index in
            let habit = habits[index]
            // Cancel all notifications before deleting
            NotificationManager.shared.cancelReminder(for: habit)
            context.delete(habit)
        }
        saveContext()
    }
    
    func toggleHabitCompletion(habit: Habit, date: Date) {
        guard habit.id != nil else { return }
        
        var currentDates = habit.completedDatesArray
        let calendar = Calendar.current
        
        if let existingIndex = currentDates.firstIndex(where: { calendar.isDate($0, inSameDayAs: date) }) {
            currentDates.remove(at: existingIndex)
        } else {
            currentDates.append(date)
        }
        
        habit.completedDatesArray = currentDates
        
        if saveContext() {
            NotificationManager.shared.updateNotification(for: habit)
        }
    }
    
    func fetchHabits() {
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
            print(error.localizedDescription)
            habits = []
        }
    }
    
    // MARK: - Weekly Reset
    func resetWeeklyProgressIfNeeded() {
        for habit in habits {
            if let lastWeekStart = habit.weeklyProgress?.start {
                if !Calendar.current.isDate(lastWeekStart, inCurrentWeekFor: Date()) {
                    habit.datesCompleted = [] as NSObject
                    if saveContext() {
                        NotificationManager.shared.updateNotification(for: habit)
                        print("🔁 Weekly reset for \(habit.name ?? "")")
                    }
                }
            } else {
                NotificationManager.shared.updateNotification(for: habit)
            }
        }
    }
    
    // MARK: - Private Save
    @discardableResult
    private func saveContext() -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            fetchHabits()
            return true
        } catch {
            authError = "Failed to save: \(error.localizedDescription)"
            print(error.localizedDescription)
            return false
        }
    }
}
