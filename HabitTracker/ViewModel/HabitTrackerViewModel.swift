//
//  TitleMonth.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 24/08/25.
//
import Foundation
import SwiftUI
import CoreData
import FirebaseAuth
class HabitTrackerViewModel: ObservableObject {
    
    @Published var habits: [Habit] = []
    @Published var currentUser: User?
    @Published var authError: String?
    
    private let context: NSManagedObjectContext
    private let userDefaultsKey = "loggedInUserId"

    // MARK: - Init
    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.context = context
        restoreLoggedInUser()
    }

    // MARK: - Restore User
    private func restoreLoggedInUser() {
        guard let uid = UserDefaults.standard.string(forKey: userDefaultsKey) else { return }

        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", uid)
        request.fetchLimit = 1

        if let user = try? context.fetch(request).first {
            currentUser = user
            fetchHabits()
        }
    }

    // MARK: - Set User
    func setLoggedInUser(_ user: User) {
        currentUser = user
        if let uid = user.userId {
            UserDefaults.standard.set(uid, forKey: userDefaultsKey)
        }
    }

    // MARK: - Clear User
    func clearLoggedInUser() {
        currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }

    // MARK: - Sign Up
    func signUpUser(email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                self.authError = error.localizedDescription
                completion(false)
                return
            }
            
            guard let firebaseUser = result?.user else {
                self.authError = "User creation failed"
                completion(false)
                return
            }
            
            // Save displayName
            let change = firebaseUser.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges(completion: nil)

            // Save to Core Data
            self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)

            // Fetch local user & set logged in
            if let localUser = self.fetchLocalUser(by: firebaseUser.uid) {
                self.setLoggedInUser(localUser)
            }

            completion(true)
        }
    }

    // MARK: - Save User Locally
    private func saveUserLocally(uid: String, email: String, name: String) {
        let localUser = User(context: context)
        localUser.userId = uid
        localUser.userEmail = email
        localUser.userName = name
        try? context.save()
    }

    // MARK: - Fetch Local
    private func fetchLocalUser(by uid: String) -> User? {
        let request = User.fetchRequest()
        request.predicate = NSPredicate(format: "userId == %@", uid)
        request.fetchLimit = 1
        return try? context.fetch(request).first
    }

    // MARK: - Sign In
    func signInUser(email: String, password: String, completion: @escaping (Bool) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            
            if let error = error {
                self.authError = error.localizedDescription
                completion(false)
                return
            }

            guard let firebaseUser = result?.user else {
                self.authError = "User not found"
                completion(false)
                return
            }

            let name = firebaseUser.displayName ?? ""

            // Save/update local user
            self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)

            // Fetch from Core Data
            if let localUser = self.fetchLocalUser(by: firebaseUser.uid) {
                self.setLoggedInUser(localUser)
            }

            self.fetchHabits()
            completion(true)
        }
    }

    // MARK: - Sign Out
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            clearLocalUser()
            clearLoggedInUser()
            habits = []
            return true
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
            return false
        }
    }

    private func clearLocalUser() {
        let request = User.fetchRequest()
        if let users = try? context.fetch(request) {
            for user in users { context.delete(user) }
        }
        try? context.save()
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
     func saveContext() -> Bool {
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
