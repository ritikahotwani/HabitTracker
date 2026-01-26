//
//  NotificationManager.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 11/10/25.
//

import Foundation
import UserNotifications
import SwiftUI
import CoreData

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // MARK: - Request Notification Permission
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            print(granted ? "✅ Permission granted" : "🚫 Permission denied")
        }
    }

    // MARK: - Combined Daily Habit Reminder (ONE notification)
    func scheduleCombinedMorningNotification(for habits: [Habit]) {
        // Remove old combined reminder (if any) to avoid duplicates
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["dailyCombinedReminder"])

        // Filter habits that:
        // - have notifications enabled
        // - are set to DEFAULT time (8:00 AM)
        // - have not yet met their weekly goal
        // - are NOT completed for today
        let pendingHabits: [Habit] = habits.filter { habit in
            guard habit.isNotify?.boolValue ?? true else { return false }
            
            // Only include habits with Default Time
            guard habit.isDefaultTime?.boolValue ?? true else { return false }

            // Check if completed Today
            let isCompletedToday = habit.completedDatesArray.contains { 
                Calendar.current.isDateInToday($0) 
            }
            if isCompletedToday { return false }

            let weeklyGoal = habit.noOfDays?.intValue ?? 7
            let completedCount = habit.completedDatesArray.filter {
                Calendar.current.isDate($0, inCurrentWeekFor: Date())
            }.count

            return completedCount < weeklyGoal
        }

        // If nothing is pending, don't schedule anything
        guard !pendingHabits.isEmpty else {
            print("ℹ️ No pending habits, skipping combined morning notification.")
            return
        }

        let names = pendingHabits.compactMap { $0.name }.joined(separator: ", ")

        let content = UNMutableNotificationContent()
        content.title = "Your habits for today 💛"
        content.body = "Today's habits: \(names)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: NotificationManager.defaultTime(),
            repeats: true
        )

        let request = UNNotificationRequest(
            identifier: "dailyCombinedReminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling combined reminder:", error.localizedDescription)
            } else {
                print("🔔 Combined daily reminder scheduled for habits: \(names)")
            }
        }
    }

    // MARK: - (Optional) Per-habit Daily Reminder (not used for now)
    // You can keep this for future use, but don't call it if you only want ONE notification.
    // MARK: - Custom Daily Reminder (Individual)
    func scheduleCustomReminder(for habit: Habit, at date: Date) {
        guard let id = habit.id?.uuidString,
              let name = habit.name,
              habit.isNotify?.boolValue ?? true else { return }

        // Universal Check: If completed today, do NOT schedule (wait for next sync/tomorrow)
        let isCompletedToday = habit.completedDatesArray.contains {
            Calendar.current.isDateInToday($0)
        }
        if isCompletedToday {
            print("✅ \(name) completed today. Skipping custom reminder schedule.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder 💪"
        content.body = "Time for your habit: \(name)"
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Use habit ID as identifier so we can cancel it individually
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling custom reminder for \(name):", error.localizedDescription)
            } else {
                print("🔔 Custom reminder scheduled for \(name) at \(components.hour ?? 0):\(components.minute ?? 0)")
            }
        }
    }
    
    // MARK: - Reschedule All (App Launch / Scene Phase)
    func rescheduleAllNotifications(for habits: [Habit]) {
        // 1. Schedule Combined (it handles its own filtering)
        scheduleCombinedMorningNotification(for: habits)
        
        // 2. Schedule Weekly Consistency
        scheduleWeeklyConsistencyNotification(for: habits)
        
        // 3. Schedule Custom Reminders
        let customHabits = habits.filter { habit in
            let isDefault = habit.isDefaultTime?.boolValue ?? true
            return !isDefault
        }
        
        for habit in customHabits {
             // Cancel first to ensure clean state? 
             // Or primarily relied on identifying by ID replacing existing one.
             if let reminderTime = habit.reminderTime {
                 scheduleCustomReminder(for: habit, at: reminderTime)
             }
        }
    }

    // MARK: - Best Streak Reminder (Evening, smart)
    func scheduleBestStreakReminder(for habit: Habit) {
        guard let id = habit.id?.uuidString,
              let name = habit.name else { return }

        let weeklyGoal = habit.noOfDays?.intValue ?? 7
        let completedCount = habit.completedDatesArray.filter {
            Calendar.current.isDate($0, inCurrentWeekFor: Date())
        }.count
        
        // Universal Check: If completed today, don't nag.
        let isCompletedToday = habit.completedDatesArray.contains {
            Calendar.current.isDateInToday($0)
        }
        if isCompletedToday { return }

        let daysRemaining = weeklyGoal - completedCount

        // Only remind when exactly 1 day is left
        guard daysRemaining == 1 else {
            print("ℹ️ No streak reminder needed for \(name). Days remaining: \(daysRemaining)")
            return
        }

        // Ensure only ONE pending streak reminder: remove old one if any
        let streakIdentifier = "\(id)_streak"
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [streakIdentifier])

        // 8 PM reminder
        var reminderTime = DateComponents()
        reminderTime.hour = 20   // 20 = 8 PM
        reminderTime.minute = 0

        let content = UNMutableNotificationContent()
        content.title = "You're so close! 🔥"
        content.body = "Only one day left to complete your weekly \(name) goal!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: reminderTime, repeats: false)

        let request = UNNotificationRequest(
            identifier: streakIdentifier,
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Streak reminder error:", error.localizedDescription)
            } else {
                print("🌙 Evening streak reminder set for \(name) at 8 PM")
            }
        }
    }



    // MARK: - Weekly Consistency Reminder (Sunday 10 PM)
    func scheduleWeeklyConsistencyNotification(for habits: [Habit]) {
        // 1. Calculate completions for current week
        var habitsWithCounts: [(habit: Habit, count: Int)] = []
        
        for habit in habits {
            let count = habit.weeklyCompletedCount
            if count > 0 {
                habitsWithCounts.append((habit, count))
            }
        }
        
        // 2. Find max
        guard let maxCount = habitsWithCounts.map({ $0.count }).max(), maxCount > 0 else {
            // No habits completed this week? Cancel any existing weekly reminder
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["weeklyConsistency"])
            return
        }
        
        // 3. Find winners
        let winners = habitsWithCounts.filter { $0.count == maxCount }
        let winnerNames = winners.compactMap { $0.habit.name }
        
        guard !winnerNames.isEmpty else { return }
        
        // 4. Content
        let content = UNMutableNotificationContent()
        content.title = "Habit you showed up for the most 💪"
        
        let joinedNames = winnerNames.joined(separator: ", ")
        content.body = "You crushed it this week with: \(joinedNames)!"
        content.sound = .default
        
        // 5. Trigger: Last day of the active week at 10:00 PM
        // Logic: If week starts on Sunday (1), last day is Saturday (7).
        // If week starts on Monday (2), last day is Sunday (1).
        // Formula: (firstWeekday + 5) % 7 + 1
        let firstWeekday = Calendar.current.firstWeekday
        let lastWeekday = (firstWeekday + 5) % 7 + 1
        
        var dateComponents = DateComponents()
        dateComponents.weekday = lastWeekday
        dateComponents.hour = 22   // 10 PM
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: "weeklyConsistency",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Weekly consistency error:", error.localizedDescription)
            } else {
                print("🏆 Weekly consistency check set for week day \(lastWeekday) at 10PM. Likely winners: \(joinedNames)")
            }
        }
    }

    // MARK: - Cancel Reminders for a Habit
    func cancelReminder(for habit: Habit) {
        guard let id = habit.id?.uuidString else { return }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id, "\(id)_streak"])
        print("🗑️ Cancelled reminders for \(habit.name ?? "")")
    }
    
    // MARK: - Cancel ALL Notifications (used on logout)
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("🗑️ All notifications cancelled (logout).")
    }

    // MARK: - Update Notifications for a single habit + recompute combined
    func updateNotifications(afterChanging habit: Habit, allHabits: [Habit]) {
        // Clear habit-specific notifications (streak / per-habit if used)
        cancelReminder(for: habit)

        // Re-schedule streak reminder for this habit
        scheduleBestStreakReminder(for: habit)

        // Re-schedule the ONE combined morning reminder for all habits
        scheduleCombinedMorningNotification(for: allHabits)
    }

    // MARK: - Default Reminder Time
    static func defaultTime() -> DateComponents {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return components
    }
    private func weekOfYear(_ date: Date) -> String {
        let week = Calendar.current.component(.weekOfYear, from: date)
        let year = Calendar.current.component(.yearForWeekOfYear, from: date)
        return "\(year)-\(week)"
    }

    //  NEW: Trigger a sign-in success notification
    func showSignInSuccessNotification(for name: String) {
        let content = UNMutableNotificationContent()
        content.title = "You’re In ✨"
        content.body = "\(name), consistency looks really good on you."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "signInSuccess", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling sign-in notification:", error)
            } else {
                print("✅ Sign-in notification scheduled")
            }
        }
    }
}
