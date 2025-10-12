//
//  NotificationManager.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 11/10/25.
//

import Foundation
import UserNotifications
import  SwiftUI
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

    // MARK: - Daily Habit Reminder
    func scheduleDailyReminder(for habit: Habit, at time: DateComponents = defaultTime()) {
        guard let id = habit.id?.uuidString,
              let name = habit.name,
              habit.isNotify?.boolValue ?? true else { return } // <--- respect toggle

        // Only schedule if weekly goal not met
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
        guard let id = habit.id?.uuidString, let name = habit.name else { return }

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

        var dateComponents = NotificationManager.defaultTime()
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "\(id)_streak", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Streak reminder error:", error.localizedDescription)
            } else {
                print("🎯 Streak reminder set for \(name)")
            }
        }
    }

    // MARK: - Cancel Reminders
    func cancelReminder(for habit: Habit) {
        guard let id = habit.id?.uuidString else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id, "\(id)_streak"])
        print("🗑️ Cancelled all reminders for \(habit.name ?? "")")
    }

    // MARK: - Update Notifications
    func updateNotification(for habit: Habit) {
        cancelReminder(for: habit)
        scheduleDailyReminder(for: habit)
        scheduleBestStreakReminder(for: habit)
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

          // Trigger immediately (1 second delay)
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

