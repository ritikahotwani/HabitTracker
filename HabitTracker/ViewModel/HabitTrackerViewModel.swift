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
    @Published var showSessionExpiredAlert: Bool = false
    @Published var showAccountDeletedAlert: Bool = false

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

    // MARK: - Session Check
    func checkSession() -> Bool {
        if currentUser == nil {
            showSessionExpiredAlert = true
            return false
        }
        return true
    }


    // MARK: - Sign Up
    func signUpUser(email: String, password: String, name: String, completion: @escaping (Bool) -> Void) {

        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            
            if let error = error {
                self.authError = self.mapAuthError(error)
                completion(false)
                return
            }
            
            guard let firebaseUser = result?.user else {
                self.authError = "User creation failed. Please try again."
                completion(false)
                return
            }
            self.authError = nil
            // Save displayName
            let change = firebaseUser.createProfileChangeRequest()
            change.displayName = name
            change.commitChanges(completion: nil)

            // Save to Core Data (Idempotent)
            self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)
            
            // Set logged in user
            if let localUser = self.fetchLocalUser(by: firebaseUser.uid) {
                self.setLoggedInUser(localUser)
            }

            completion(true)
        }
    }

    // MARK: - Save User Locally
    private func saveUserLocally(uid: String, email: String, name: String) {
        // Check if user already exists
        if let existingUser = fetchLocalUser(by: uid) {
            // Update existing user
            existingUser.userEmail = email
            existingUser.userName = name
        } else {
            // Create new user
            let newUser = User(context: context)
            newUser.userId = uid
            newUser.userEmail = email
            newUser.userName = name
        }
        
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
               self.authError = self.mapAuthError(error)
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

            // Sync user data to Core Data
            self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)

            // Set Logged In User
            if let localUser = self.fetchLocalUser(by: firebaseUser.uid) {
                self.setLoggedInUser(localUser)
                self.fetchHabits()
            }
            
            completion(true)
        }
    }
    
    // MARK: - Google Sign In
    func signInWithGoogle(credential: AuthCredential, googleName: String? = nil, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(with: credential) { result, error in
            if let error = error {
                self.authError = self.mapAuthError(error)
                completion(false)
                return
            }
            
            guard let firebaseUser = result?.user else {
                self.authError = "User not found"
                completion(false)
                return
            }
            
            self.authError = nil
            
            // Use existing display name, or the one from Google, or fallback
            var finalName = firebaseUser.displayName
            if (finalName == nil || finalName?.isEmpty == true), let gName = googleName {
                 finalName = gName
                 // Update Firebase Profile
                 let change = firebaseUser.createProfileChangeRequest()
                 change.displayName = gName
                 change.commitChanges(completion: nil)
            }
            
            let name = finalName ?? "Google User"
            let email = firebaseUser.email ?? ""
            
            // Sync user data to Core Data
            self.saveUserLocally(uid: firebaseUser.uid, email: email, name: name)
            
            // Set Logged In User
            if let localUser = self.fetchLocalUser(by: firebaseUser.uid) {
                self.setLoggedInUser(localUser)
                self.fetchHabits()
            }
            
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
                    self.authError = self.mapAuthError(error)
                    self.resetPasswordSuccess = false
                } else {
                    self.authError = nil
                    self.resetPasswordSuccess = true
                }
            }
        }
    }

    // MARK: - Validate Firebase Session
    func validateAuthSession() {
        guard let user = Auth.auth().currentUser else {
            // No user logged in?
            return
        }

        user.reload { error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    // Check for specific errors
                    if error.code == AuthErrorCode.userNotFound.rawValue ||
                       error.code == AuthErrorCode.userTokenExpired.rawValue ||
                       error.code == AuthErrorCode.userDisabled.rawValue {
                         
                        // Instead of silent sign out, show alert
                        self.showAccountDeletedAlert = true
                    }
                    print("Session validation failed: \(error.localizedDescription)")
                }
            }
        }
    }



    private func signOutSilently() {
        clearLoggedInUser()
        habits = []
        currentUser = nil
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
      guard checkSession(), let user = currentUser else { return }

      // Validation
      guard !name.trimmingCharacters(in: .whitespaces).isEmpty else { return }
      if habits.count >= 50 {
          self.authError = "You have reached the maximum limit of 50 habits."
          return
      }

        validateAuthSession()
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
        
        guard checkSession() else { return }
        validateAuthSession()
        
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
        guard checkSession() else { return }
        validateAuthSession()

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
        guard checkSession() else { return }
        validateAuthSession()

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
    


    // MARK: - Delete Account (Permanent)
    func deleteAccount(completion: @escaping (Bool) -> Void = { _ in }) {

        guard let firebaseUser = Auth.auth().currentUser,
              let localUser = currentUser else {
            authError = "User not found"
            completion(false)
            return
        }

        // 1️⃣ FIRST: Delete Firebase user
        firebaseUser.delete { error in
            DispatchQueue.main.async {

                if let error = error {
                    self.authError = self.mapAuthError(error)
                    completion(false)
                    return
                }

                // 2️⃣ Cancel all notifications
                NotificationManager.shared.cancelAllNotifications()

                // 3️⃣ Delete habits
                let habitRequest = Habit.fetchRequest()
                habitRequest.predicate = NSPredicate(format: "user == %@", localUser)

                if let userHabits = try? self.context.fetch(habitRequest) {
                    userHabits.forEach { self.context.delete($0) }
                }

                // 4️⃣ Delete user entity
                self.context.delete(localUser)

                // 5️⃣ Save Core Data
                guard self.saveContext() else {
                    self.authError = "Failed to delete local data"
                    completion(false)
                    return
                }

                // 6️⃣ Clear app state
                self.clearLoggedInUser()
                self.habits = []
                self.currentUser = nil
                self.authError = nil

                completion(true)
            }
        }
    }


    
    // MARK: - Map Auth Error
    private func mapAuthError(_ error: Error) -> String {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue:
            return "Incorrect password. Please try again."
        case AuthErrorCode.userNotFound.rawValue:
            return "No account found with this email."
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return "This email is already in use. Please sign in instead."
        case AuthErrorCode.invalidEmail.rawValue:
            return "The email address is badly formatted."
        case AuthErrorCode.weakPassword.rawValue:
            return "Password should be at least 6 characters."
        case AuthErrorCode.networkError.rawValue:
            return "Network connection error. Please check your internet."
        case AuthErrorCode.requiresRecentLogin.rawValue:
            return "For security reasons, please log in again to delete your account."
        default:
            return error.localizedDescription
        }
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
            authError = "Unable to save changes. Please try again."
            print(error.localizedDescription)
            return false
        }
    }
}
