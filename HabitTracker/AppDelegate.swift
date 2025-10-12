//
//  AppDelegate.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 11/10/25.
//

import UIKit
import CoreData
import UserNotifications


class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Fixes UIScene lifecycle warning and black screen
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Background fetch triggered")
        resetWeeklyProgressIfNeeded()
        completionHandler(.newData)
    }
    
    private func resetWeeklyProgressIfNeeded() {
        let viewContext = PersistenceController.shared.container.viewContext
        let habits = fetchAllHabits(context: viewContext)
        
        for habit in habits {
            if let lastWeekStart = habit.weeklyProgress?.start {
                if !Calendar.current.isDate(lastWeekStart, inCurrentWeekFor: Date()) {
                    habit.datesCompleted = [] as NSObject
                    try? viewContext.save()
                    print("🔁 Weekly reset for \(habit.name ?? "")")
                }
            }
        }
    }
    
    private func fetchAllHabits(context: NSManagedObjectContext) -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching habits:", error)
            return []
        }
    }
    
    // MARK: - Notification Handling
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let habitId = response.notification.request.identifier
        print("User tapped notification for habit: \(habitId)")
        completionHandler()
    }
}

