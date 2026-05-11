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
                .onOpenURL { url in
                    guard url.scheme == "habittracker" else { return }
                    switch url.host {
                    case "select-habit":
                        appState.showWidgetHabitPicker = true
                    case "add-habit":
                        appState.showAddHabit = true
                    case "home":
                        appState.navigateToHome = true
                    case "habit-details":
                        if let uuidString = url.pathComponents.last,
                           let uuid = UUID(uuidString: uuidString) {
                            appState.deepLinkHabitID = uuid
                        }
                    default:
                        break
                    }
                }
        }

        .onChange(of: scenePhase) { phase in
            if phase == .active {

                viewModel.validateAuthSession()
                NotificationManager.shared.rescheduleAllNotifications(for: viewModel.habits)
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












