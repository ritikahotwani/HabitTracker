//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI
import CoreData
import UserNotifications
import FirebaseAuth
@main
struct HabitTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var appState = AppState()
    @StateObject var viewModel = HabitTrackerViewModel()
    @AppStorage("appTheme") private var appTheme: AppTheme = .system
    @Environment(\.scenePhase) private var scenePhase
    let viewContext = PersistenceController.shared.container.viewContext

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .environmentObject(viewModel)
                .environment(\.managedObjectContext, viewContext)
                .preferredColorScheme(resolvedColorScheme)
        }
        
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                let habits = fetchAllHabits(context: viewContext)
                resetWeeklyProgressIfNeeded(viewContext: viewContext, habits: habits)
            }
        }
       

        
    }
    private var resolvedColorScheme: ColorScheme? {
          switch appTheme {
          case .system:
              return nil
          case .light:
              return .light
          case .dark:
              return .dark
          }
      }

    // MARK: - Fetch All Habits
    private func fetchAllHabits(context: NSManagedObjectContext) -> [Habit] {
        let request: NSFetchRequest<Habit> = Habit.fetchRequest()
        do {
            return try context.fetch(request)
        } catch {
            print("❌ Error fetching habits:", error)
            return []
        }
    }

    // MARK: - Weekly Reset + Notifications
    private func resetWeeklyProgressIfNeeded(viewContext: NSManagedObjectContext, habits: [Habit]) {
        var habitsChanged = false

        for habit in habits {
            if let lastWeekStart = habit.weeklyProgress?.start {
                if !Calendar.current.isDate(lastWeekStart, inCurrentWeekFor: Date()) {
                    habit.datesCompleted = [] as NSObject
                    habitsChanged = true
                }
            } else {
                // New habit without weeklyProgress considered as changed
                habitsChanged = true
            }
        }

        if habitsChanged {
            do {
                try viewContext.save()
                // After weekly reset: schedule streak reminders for each habit
                for habit in habits {
                    NotificationManager.shared.scheduleBestStreakReminder(for: habit)
                }
                // After everything: re-schedule combined morning notification
                NotificationManager.shared.scheduleCombinedMorningNotification(for: habits)

                print("🔁 Weekly reset + notifications updated")
            } catch {
                print("❌ Failed to save weekly reset:", error)
            }
        }
    }

}












