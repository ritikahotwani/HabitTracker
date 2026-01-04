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

        .onChange(of: scenePhase) { phase in
            if phase == .active {
                viewModel.resetWeeklyProgressIfNeeded()
                viewModel.validateAuthSession()
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

}












