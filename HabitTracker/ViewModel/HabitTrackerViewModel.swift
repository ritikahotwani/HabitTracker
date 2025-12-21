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
    @Published var resetPasswordSuccess: Bool = false

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
            self.authError = nil
            // Save displayName
            let change = firebaseUser.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges(completion: nil)

            // Save to Core Data
//            self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)
            if let localUser = self.fetchLocalUser(by: firebaseUser.uid) {
                // already exists → don’t create again
                self.setLoggedInUser(localUser)
            } else {
                // create for the first time
                self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)
                if let newUser = self.fetchLocalUser(by: firebaseUser.uid) {
                    self.setLoggedInUser(newUser)
                }
            }


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
            self.authError = nil
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
    // MARK: - Forgot Password
    func resetPassword(email: String) {
        guard !email.isEmpty else {
            authError = "Please enter your email address"
            resetPasswordSuccess = false
            return
        }

        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error {
                    self.authError = error.localizedDescription
                    self.resetPasswordSuccess = false
                } else {
                    self.authError = nil
                    self.resetPasswordSuccess = true
                }
            }
        }
    }

    
    // MARK: - Sign Out
    func signOut() -> Bool {
        do {
            try Auth.auth().signOut()
            clearLoggedInUser()
            NotificationManager.shared.cancelAllNotifications()
            habits = []
            return true
        } catch {
            print("Sign-out error: \(error.localizedDescription)")
            return false
        }
    }

    
    // MARK: - Habit CRUD + Notifications
    func addHabit(name: String,
                  icon: String,
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
        self.authError = nil
        let habit = Habit(context: context)
        habit.user = user
        habit.name = name
        habit.icon = icon
        habit.id = UUID()
        habit.datesCompleted = [] as NSObject
        habit.priorityColor = priorityColor
        habit.frequency = frequency
        habit.startDate = Date()
        habit.note = note
        habit.noOfDays = NSNumber(value: noOfDays)
        habit.isNotify = NSNumber(value: isNotify)
        
        if saveContext() {
            if isNotify {
                // Streak reminder for this habit
                NotificationManager.shared.scheduleBestStreakReminder(for: habit)
            } else {
                NotificationManager.shared.cancelReminder(for: habit)
            }
            // Recreate the ONE combined morning notification using updated habits list
            NotificationManager.shared.scheduleCombinedMorningNotification(for: habits)

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
                NotificationManager.shared.scheduleBestStreakReminder(for: habit)
            } else {
                NotificationManager.shared.cancelReminder(for: habit)
            }

            NotificationManager.shared.scheduleCombinedMorningNotification(for: habits)
            completion?()
        }

    }
    
    func deleteHabit(offsets: IndexSet) {
        offsets.forEach { index in
            let habit = habits[index]
            NotificationManager.shared.cancelReminder(for: habit)
            context.delete(habit)
        }
        if saveContext() {
            NotificationManager.shared.scheduleCombinedMorningNotification(for: habits)
        }
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
            let weeklyGoal = habit.noOfDays?.intValue ?? 7
            let completedCountThisWeek = habit.completedDatesArray.filter {
                Calendar.current.isDate($0, inCurrentWeekFor: Date())
            }.count

            if completedCountThisWeek >= weeklyGoal {
                NotificationManager.shared.cancelReminder(for: habit)
                print("✅ Weekly goal met for \(habit.name ?? ""). Cancelling evening streak reminder.")
            } else {
                NotificationManager.shared.scheduleBestStreakReminder(for: habit)
            }
            NotificationManager.shared.scheduleCombinedMorningNotification(for: habits)
        }
    }

    
    func fetchHabits() {
        guard let user = currentUser else {
            habits = []
            return
        }
        
        let request = Habit.fetchRequest()
        request.predicate = NSPredicate(format: "user == %@", user)
//        request.sortDescriptors = [NSSortDescriptor(key: "startDate", ascending: false)]
        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true),
            NSSortDescriptor(key: "startDate", ascending: false)
        ]

        
        do {
            habits = try context.fetch(request)
           authError = nil
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
                        NotificationManager.shared.scheduleBestStreakReminder(for: habit)
                        print("🔁 Weekly reset for \(habit.name ?? "")")
                    }
                }
            } else {
                NotificationManager.shared.scheduleBestStreakReminder(for: habit)
            }
        }

        // After any changes, update the combined notification
        NotificationManager.shared.scheduleCombinedMorningNotification(for: habits)
    }

    
    // MARK: - Private Save
    @discardableResult
     func saveContext() -> Bool {
        guard context.hasChanges else { return true }
        do {
            try context.save()
            fetchHabits()
            authError = nil
            return true
        } catch {
            authError = "Failed to save: \(error.localizedDescription)"
            print(error.localizedDescription)
            return false
        }
    }
}
