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

    // MARK: - 🔔 Combined Daily Habit Reminder (ONE notification)
    func scheduleCombinedMorningNotification(for habits: [Habit]) {
        // Remove old combined reminder (if any) to avoid duplicates
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["dailyCombinedReminder"])

        // Filter habits that:
        // - have notifications enabled
        // - have not yet met their weekly goal
        let pendingHabits: [Habit] = habits.filter { habit in
            guard habit.isNotify?.boolValue ?? true else { return false }

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
    func scheduleDailyReminder(for habit: Habit, at time: DateComponents = defaultTime()) {
        guard let id = habit.id?.uuidString,
              let name = habit.name,
              habit.isNotify?.boolValue ?? true else { return }

        let weeklyGoal = habit.noOfDays?.intValue ?? 7
        let completedCount = habit.completedDatesArray.filter {
            Calendar.current.isDate($0, inCurrentWeekFor: Date())
        }.count
        guard completedCount < weeklyGoal else { return }

        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder 💪"
        content.body = "Time for your habit: \(name)"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: time, repeats: true)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Error scheduling daily reminder:", error.localizedDescription)
            } else {
                print("🔔 Daily reminder scheduled for \(name)")
            }
        }
    }

    // MARK: - Best Streak Reminder
    func scheduleBestStreakReminder(for habit: Habit) {
        guard let id = habit.id?.uuidString,
              let name = habit.name else { return }

        let weeklyGoal = habit.noOfDays?.intValue ?? 7
        let completedCount = habit.completedDatesArray.filter {
            Calendar.current.isDate($0, inCurrentWeekFor: Date())
        }.count

        let daysRemaining = max(weeklyGoal - completedCount, 0)
        guard daysRemaining > 0 else { return } // Goal already met

        let content = UNMutableNotificationContent()
        content.title = "Keep Going! 🔥"
        content.body = "Only \(daysRemaining) day(s) left to beat your best streak in \(name)!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: NotificationManager.defaultTime(),
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "\(id)_streak",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Streak reminder error:", error.localizedDescription)
            } else {
                print("🎯 Streak reminder set for \(name)")
            }
        }
    }

    // MARK: - Cancel Reminders for a Habit
    func cancelReminder(for habit: Habit) {
        guard let id = habit.id?.uuidString else { return }
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [id, "\(id)_streak"])
        print("🗑️ Cancelled all reminders for \(habit.name ?? "")")
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

    // ✅ NEW: Trigger a sign-in success notification
    func showSignInSuccessNotification(for email: String) {
        let content = UNMutableNotificationContent()
        content.title = "🎉 Welcome love!"
        content.body = "You're signed in as \(email). Stay consistent with your habits today!"
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
