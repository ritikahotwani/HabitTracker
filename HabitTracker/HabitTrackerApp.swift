//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Ritika Hotwani on 13/08/25.
//

import SwiftUI
import CoreData
import UserNotifications

@main
struct HabitTrackerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var appState = AppState()
    @StateObject var viewModel = HabitTrackerViewModel()
    @Environment(\.scenePhase) private var scenePhase

    let viewContext = PersistenceController.shared.container.viewContext
    @State private var showSplash = true

    init() {
        NotificationManager.shared.requestPermission()
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen()
                        .transition(.opacity)
                } else {
                    ContentView()
                        .environmentObject(appState)
                        .environmentObject(viewModel)
                        .environment(\.managedObjectContext, viewContext)
                        .transition(.opacity)
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        showSplash = false
                    }
                }
            }
            .animation(.easeInOut(duration: 0.5), value: showSplash)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                let habits = fetchAllHabits(context: viewContext)
                resetWeeklyProgressIfNeeded(viewContext: viewContext, habits: habits)
            }
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
        for habit in habits {
            if let lastWeekStart = habit.weeklyProgress?.start {
                if !Calendar.current.isDate(lastWeekStart, inCurrentWeekFor: Date()) {
                    habit.datesCompleted = [] as NSObject
                    do {
                        try viewContext.save()
                        NotificationManager.shared.updateNotification(for: habit)
                        print("🔁 Weekly reset for \(habit.name ?? "")")
                    } catch {
                        print("❌ Failed to save weekly reset:", error)
                    }
                }
            } else {
                // Handle new habit without weeklyProgress
                NotificationManager.shared.updateNotification(for: habit)
            }
        }
    }
}












